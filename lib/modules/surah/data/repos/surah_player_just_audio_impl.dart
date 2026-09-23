import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_meta_data_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';

import '../../domain/surah_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Helper Components (Single Responsibility Principle)
// ─────────────────────────────────────────────────────────────────────────────

/// Stateful iterator that walks through the playback sequence on demand.
///
/// Supports two modes:
/// - `ayaRepeatCount == 1`: each surah in range is one clip (gapless).
/// - `ayaRepeatCount > 1`: each ayah is a separate clip, repeated N times.
///
/// Section repeats replay the entire range from start.
class _Counter {
  late SurahPlayParams _params;

  int _currentSurahNumber = 1;
  int get currentSurahNumber => _currentSurahNumber;

  int _currentAya = 1;
  int get currentAya => _currentAya;

  int _currentAyaRepeat = 1;
  int get currentAyaRepeat => _currentAyaRepeat;

  int _currentSectionRepeat = 1;
  int get currentSectionRepeat => _currentSectionRepeat;

  bool _isFinished = true;
  bool get isFinished => _isFinished;

  /// Clip start ayah — full surah range when ayaRepeatCount == 1.
  int get startAya {
    if (_params.ayaRepeatCount == 1) {
      return (_currentSurahNumber == _params.startSurahNumber)
          ? _params.startAya
          : 1;
    }
    return _currentAya;
  }

  /// Clip end ayah — full surah range when ayaRepeatCount == 1.
  int get endAya {
    if (_params.ayaRepeatCount == 1) {
      return lastAyaOfCurrentSurah;
    }
    return _currentAya;
  }

  void reset(SurahPlayParams params) {
    _params = params;
    _currentSurahNumber = params.startSurahNumber;
    _currentAya = params.startAya;
    _currentAyaRepeat = 1;
    _currentSectionRepeat = 1;
    _isFinished = false;
  }

  void increment() {
    if (_isFinished) return;

    if (_params.ayaRepeatCount == 1) {
      _incrementSurah();
    } else if (_currentAyaRepeat < _params.ayaRepeatCount) {
      _currentAyaRepeat++;
    } else {
      _currentAyaRepeat = 1;
      _incrementAya();
    }
  }

  void _incrementAya() {
    if (_currentAya < lastAyaOfCurrentSurah) {
      _currentAya++;
    } else {
      _incrementSurah();
    }
  }

  void _incrementSurah() {
    if (_currentSurahNumber < _params.endSurahNumber) {
      _currentSurahNumber++;
      _currentAya = 1;
    } else {
      _resetOrFinish();
    }
  }

  void _resetOrFinish() {
    if (_currentSectionRepeat < _params.sectionRepeatCount) {
      _currentSectionRepeat++;
      _currentSurahNumber = _params.startSurahNumber;
      _currentAya = _params.startAya;
    } else {
      _isFinished = true;
    }
  }

  int get lastAyaOfCurrentSurah {
    if (_currentSurahNumber == _params.endSurahNumber) {
      return _params.endAya;
    }
    return SUR[_currentSurahNumber - 1].versesCount;
  }
}

/// Responsible for fetching and caching Surah Ayah timings per reader.
class _SurahTimingsManager {
  final SurahAPI _api = SurahAPI();
  final Map<int, List<AyaMetaDataModel>> _cache = {};
  int? _cachedReaderId;

  /// Retrieves cached timings or fetches them from the API if reader changes.
  Future<List<AyaMetaDataModel>> getTimings(
    int surahNumber,
    ReaderModel reader,
  ) async {
    if (_cachedReaderId != reader.id) {
      _cache.clear();
      _cachedReaderId = reader.id;
    }

    if (_cache.containsKey(surahNumber)) {
      return _cache[surahNumber]!;
    }

    try {
      final timings = await _api.getTiming(surahNumber, reader.id);
      _cache[surahNumber] = timings;
      return timings;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Main Service Implementation
// ─────────────────────────────────────────────────────────────────────────────

/// High-level audio player implementation combining `just_audio` and `audio_service`.
class SurahPlayerJustAudioImpl extends BaseAudioHandler implements SurahPlayer {
  // --- Infrastructure & Controllers ---
  final AudioPlayer _player = AudioPlayer();
  final _SurahTimingsManager _timingsManager = _SurahTimingsManager();
  final StreamController<SurahPlayerState> _stateController =
      StreamController<SurahPlayerState>.broadcast();

  // --- Counter & Params ---
  late SurahPlayParams _currentPlayParams;
  final _Counter _counter = _Counter();

  // --- State Tracking ---
  SurahPlayerState _lastState = SurahPlayerState.idel;
  static bool _permissionsRequested = false;
  bool _isQueueUpdating = false;
  bool _isActive = false;

  StreamSubscription? _currentIndexSub;

  // --- Singleton Management ---
  static SurahPlayerJustAudioImpl? _instance;
  static SurahPlayerJustAudioImpl get instance {
    if (_instance == null) {
      throw Exception(
        'SurahPlayerJustAudioImpl not initialized. Call `SurahPlayerJustAudioImpl.init()` in main before `runApp()`.',
      );
    }
    return _instance!;
  }

  static Future<void> init() async {
    _instance = await AudioService.init(
      builder: () => SurahPlayerJustAudioImpl._(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'tahfez.allam.labs.playback',
        androidNotificationChannelName: 'Quran Playback',
        androidStopForegroundOnPause: false,
      ),
    );
  }

  SurahPlayerJustAudioImpl._() {
    _setupListeners();
  }

  void _setupListeners() {
    _player.playerStateStream.listen(_onPlayerStateChanged);

    // Sliding window advancement:
    // When track 0 finishes and track 1 begins playing, index emits 1.
    // We drop track 0 and append the next scheduled track.
    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == 1) _onTrackCompleted();
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Public Contract: SurahPlayer & BaseAudioHandler Overrides
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Future<void> start(SurahPlayParams params) async {
    await _ensurePermissionsGranted();
    await _startPlayback(params);
  }

  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async {
    await _stopAndReset();
  }

  @override
  Future<void> onTaskRemoved() async {
    // Preserves background audio playback when app recents is swiped away.
  }

  @override
  Future<void> dispose() async {
    await _currentIndexSub?.cancel();
    await _player.dispose();
  }

  @override
  Stream<SurahPlayerState> get state async* {
    yield _lastState;
    yield* _stateController.stream;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Playback Control & Queue Orchestration
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _startPlayback(SurahPlayParams params) async {
    _emit(SurahPlayerState.loading);
    await _player.stop();

    try {
      _currentPlayParams = params;
      _counter.reset(params);
      _isActive = true;

      // Fill initial sliding window (up to 3 sources)
      final sources = <AudioSource>[];
      MediaItem? firstMediaItem;
      for (int i = 0; i < 3; i++) {
        final source = await _takeNextSource();
        if (source == null) break;
        firstMediaItem ??= source.tag as MediaItem;
        sources.add(source);
      }

      if (sources.isEmpty) {
        _isActive = false;
        _emit(SurahPlayerState.idel);
        return;
      }

      // Set notification to first track's metadata
      mediaItem.add(firstMediaItem!);
      await _player.setAudioSources(sources, initialIndex: 0);
      _player.play();
    } catch (e) {
      await _stopAndReset();
      if (e is Failure) {
        rethrow;
      } else {
        throw Failure.fromException(e);
      }
    }
  }

  /// Called when track at index 0 finishes and index 1 becomes active.
  Future<void> _onTrackCompleted() async {
    if (_isQueueUpdating) return;
    _isQueueUpdating = true;

    try {
      // Update notification from the now-active source's tag
      final sequence = _player.sequenceState.sequence;
      if (sequence.length > 1) {
        final activeTag = sequence[1].tag;
        if (activeTag is MediaItem) mediaItem.add(activeTag);
      }

      // Drop completed track at head
      await _player.removeAudioSourceAt(0);

      // Append next source to tail (with error resilience)
      try {
        final next = await _takeNextSource();
        if (next != null) await _player.addAudioSource(next);
      } catch (e) {
        Log.error('Failed to queue next track: $e');
      }
    } finally {
      _isQueueUpdating = false;
      _updateNotification();
    }
  }

  /// Unified teardown: stops player, resets state, clears notification.
  Future<void> _stopAndReset() async {
    _isActive = false;
    mediaItem.add(null);
    await _player.stop();
    _emit(SurahPlayerState.idel);
    _emitPlaybackState(AudioProcessingState.idle, false);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Source Building (DRY)
  // ───────────────────────────────────────────────────────────────────────────

  /// Consumes the current counter state, builds a [ClippingAudioSource],
  /// then advances the counter. Returns null if counter is finished.
  Future<IndexedAudioSource?> _takeNextSource() async {
    if (_counter.isFinished) return null;

    final tag = _buildMediaItem();
    final timings = await _timingsManager.getTimings(
      _counter.currentSurahNumber,
      _currentPlayParams.reader,
    );

    final int startMs = timings[_counter.startAya - 1].startTime;
    final int endMs = timings[_counter.endAya - 1].endTime;

    final uri = await QuranAudioResolver.playbackUri(
      _currentPlayParams.reader,
      _counter.currentSurahNumber,
    );

    _counter.increment();

    return ClippingAudioSource(
      child: AudioSource.uri(uri),
      start: Duration(milliseconds: startMs),
      end: Duration(milliseconds: endMs),
      tag: tag,
    );
  }

  /// Builds a [MediaItem] from the current counter state for notifications.
  MediaItem _buildMediaItem() {
    final String surahName = SUR[_counter.currentSurahNumber - 1].name;
    final String ayaInfo = (_counter.startAya == _counter.endAya)
        ? 'آية ${_counter.startAya}/${_counter.lastAyaOfCurrentSurah}'
        : 'آيات ${_counter.startAya}-${_counter.endAya}';

    final String title = 'سورة $surahName ($ayaInfo)';

    final List<String> details = [];
    if (_currentPlayParams.ayaRepeatCount > 1) {
      details.add(
        'تكرار الآية: ${_counter.currentAyaRepeat}/${_currentPlayParams.ayaRepeatCount}',
      );
    }
    if (_currentPlayParams.sectionRepeatCount > 1) {
      details.add(
        'تكرار المقطع: ${_counter.currentSectionRepeat}/${_currentPlayParams.sectionRepeatCount}',
      );
    }
    if (details.isEmpty && _currentPlayParams.reader.name.isNotEmpty) {
      details.add(_currentPlayParams.reader.name);
    }

    final String subtitle = details.isNotEmpty ? details.join(' • ') : 'Tahfez';

    return MediaItem(
      id: '${_counter.currentSurahNumber}_${_counter.currentAya}_${_counter.currentAyaRepeat}_${_counter.currentSectionRepeat}',
      title: title,
      artist: subtitle,
      album: _currentPlayParams.reader.name.isNotEmpty
          ? _currentPlayParams.reader.name
          : 'Tahfez',
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // State Mapping & Notification Synchronization
  // ───────────────────────────────────────────────────────────────────────────

  void _onPlayerStateChanged(PlayerState playerState) {
    switch (playerState.processingState) {
      case ProcessingState.idle:
        if (!_isActive) {
          _stopAndReset();
        }
        break;

      case ProcessingState.loading:
        _emit(SurahPlayerState.loading);
        _emitPlaybackState(AudioProcessingState.loading, false);
        break;

      case ProcessingState.buffering:
        _emit(SurahPlayerState.loading);
        _emitPlaybackState(AudioProcessingState.buffering, playerState.playing);
        break;

      case ProcessingState.ready:
        final bool isPlaying = playerState.playing;
        _emit(isPlaying ? SurahPlayerState.play : SurahPlayerState.pause);
        _emitPlaybackState(AudioProcessingState.ready, isPlaying);
        break;

      case ProcessingState.completed:
        _stopAndReset();
        break;
    }
  }

  void _updateNotification() {
    final AudioProcessingState processing = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
    _emitPlaybackState(processing, _player.playing);
  }

  void _emitPlaybackState(AudioProcessingState processingState, bool playing) {
    final bool isIdle = processingState == AudioProcessingState.idle;
    playbackState.add(
      PlaybackState(
        controls: isIdle
            ? const []
            : [
                playing ? MediaControl.pause : MediaControl.play,
                MediaControl.stop,
              ],
        androidCompactActionIndices: isIdle ? const [] : const [0, 1],
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Permissions
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _ensurePermissionsGranted() async {
    if (_permissionsRequested || !Platform.isAndroid) return;
    _permissionsRequested = true;
    try {
      await [
        Permission.notification,
        Permission.ignoreBatteryOptimizations,
      ].request();
    } catch (e) {
      Log.error(e.toString());
    }
  }

  void _emit(SurahPlayerState newState) {
    _lastState = newState;
    _stateController.add(newState);
  }
}

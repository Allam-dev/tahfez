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
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
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
  final StreamController<SurahPlaybackInfo> _statusController =
      StreamController<SurahPlaybackInfo>.broadcast();

  // --- Counter & Params ---
  late SurahPlayParams _currentPlayParams;
  final _Counter _counter = _Counter();

  // --- State Tracking ---
  SurahPlaybackInfo _lastStatus = const SurahPlaybackInfo.idle();
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
    await _statusController.close();
  }

  @override
  Stream<SurahPlaybackInfo> get status async* {
    yield _lastStatus;
    yield* _statusController.stream;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Playback Control & Queue Orchestration
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _startPlayback(SurahPlayParams params) async {
    _emitStatus(
      const SurahPlaybackInfo.idle().withState(SurahPlayerState.loading),
    );
    await _player.stop();

    try {
      _currentPlayParams = params;
      _counter.reset(params);
      _isActive = true;

      // Fill initial sliding window (up to 3 sources)
      final sources = <AudioSource>[];
      SurahPlaybackInfo? firstInfo;
      for (int i = 0; i < 3; i++) {
        final source = await _takeNextSource();
        if (source == null) break;
        firstInfo ??= source.tag as SurahPlaybackInfo;
        sources.add(source);
      }

      if (sources.isEmpty) {
        _isActive = false;
        _emitStatus(const SurahPlaybackInfo.idle());
        return;
      }

      // Set notification & emit first track's status
      mediaItem.add(_buildMediaItem(firstInfo!));
      await _player.setAudioSources(sources, initialIndex: 0);
      _emitStatus(firstInfo);
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
      // Read the now-active source's tag (SurahPlaybackInfo)
      final sequence = _player.sequenceState.sequence;
      if (sequence.length > 1) {
        final info = sequence[1].tag as SurahPlaybackInfo;
        mediaItem.add(_buildMediaItem(info));
        _emitStatus(info);
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
    _emitStatus(const SurahPlaybackInfo.idle());
    _emitPlaybackState(AudioProcessingState.idle, false);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Source Building
  // ───────────────────────────────────────────────────────────────────────────

  /// Consumes the current counter state, builds a [ClippingAudioSource]
  /// tagged with a [SurahPlaybackInfo] snapshot, then advances the counter.
  /// Returns null if counter is finished.
  Future<IndexedAudioSource?> _takeNextSource() async {
    if (_counter.isFinished) return null;

    final timings = await _timingsManager.getTimings(
      _counter.currentSurahNumber,
      _currentPlayParams.reader,
    );

    // Build playback info BEFORE incrementing the counter.
    final info = _buildStatusFromCounter(timings);

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
      tag: info,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Status & MediaItem Builders
  // ───────────────────────────────────────────────────────────────────────────

  /// Builds a [SurahPlaybackInfo] from the current [_counter] + [_currentPlayParams].
  /// Must be called before [_counter.increment()].
  SurahPlaybackInfo _buildStatusFromCounter(List<AyaMetaDataModel> timings) {
    final ayaIndex = _counter.currentAya - 1;
    return SurahPlaybackInfo(
      playerState: SurahPlayerState.play,
      surahNumber: _counter.currentSurahNumber,
      ayaMetaData: (ayaIndex >= 0 && ayaIndex < timings.length)
          ? timings[ayaIndex]
          : null,
      currentAyaRepeat: _counter.currentAyaRepeat,
      totalAyaRepeats: _currentPlayParams.ayaRepeatCount,
      currentSectionRepeat: _counter.currentSectionRepeat,
      totalSectionRepeats: _currentPlayParams.sectionRepeatCount,
    );
  }

  /// Builds a [MediaItem] for the OS notification from a [SurahPlaybackInfo].
  MediaItem _buildMediaItem(SurahPlaybackInfo info) {
    final String surahName = SUR[info.surahNumber - 1].name;
    final String ayaLabel = info.ayaMetaData != null
        ? 'آية ${info.ayaMetaData!.id}'
        : '';

    final String title = 'سورة $surahName ($ayaLabel)';

    final List<String> details = [];
    if (info.totalAyaRepeats > 1) {
      details.add(
        'تكرار الآية: ${info.currentAyaRepeat}/${info.totalAyaRepeats}',
      );
    }
    if (info.totalSectionRepeats > 1) {
      details.add(
        'تكرار المقطع: ${info.currentSectionRepeat}/${info.totalSectionRepeats}',
      );
    }
    if (details.isEmpty && _currentPlayParams.reader.name.isNotEmpty) {
      details.add(_currentPlayParams.reader.name);
    }

    final String subtitle = details.isNotEmpty ? details.join(' • ') : 'Tahfez';

    return MediaItem(
      id: '${info.surahNumber}_${info.ayaMetaData?.id ?? 0}_${info.currentAyaRepeat}_${info.currentSectionRepeat}',
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
        _emitStatus(_lastStatus.withState(SurahPlayerState.loading));
        _emitPlaybackState(AudioProcessingState.loading, false);
        break;

      case ProcessingState.buffering:
        _emitStatus(_lastStatus.withState(SurahPlayerState.loading));
        _emitPlaybackState(AudioProcessingState.buffering, playerState.playing);
        break;

      case ProcessingState.ready:
        final bool isPlaying = playerState.playing;
        _emitStatus(_lastStatus.withState(
          isPlaying ? SurahPlayerState.play : SurahPlayerState.pause,
        ));
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

  // ───────────────────────────────────────────────────────────────────────────
  // Unified Status Emission
  // ───────────────────────────────────────────────────────────────────────────

  void _emitStatus(SurahPlaybackInfo status) {
    _lastStatus = status;
    _statusController.add(status);
  }
}

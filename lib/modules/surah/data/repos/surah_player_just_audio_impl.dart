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
import 'package:tahfez/modules/surah/domain/models/aya_timing_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';

import '../../domain/surah_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Data Transfer Models & Helper Components (Single Responsibility Principle)
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single scheduled clip in the playback queue.
class _PlaybackItem {
  final ReaderModel reader;
  final int surahNumber;
  final int startAya;
  final int endAya;
  final int currentAyaRepeat;
  final int totalAyaRepeats;
  final int currentSectionRepeat;
  final int totalSectionRepeats;

  const _PlaybackItem({
    required this.reader,
    required this.surahNumber,
    required this.startAya,
    required this.endAya,
    this.currentAyaRepeat = 1,
    this.totalAyaRepeats = 1,
    this.currentSectionRepeat = 1,
    this.totalSectionRepeats = 1,
  });
}

/// Responsible for fetching and caching Surah Ayah timings per reader.
class _SurahTimingsManager {
  final SurahAPI _api = SurahAPI();
  final Map<int, List<AyaTimingModel>> _cache = {};
  int? _cachedReaderId;

  /// Retrieves cached timings or fetches them from the API if reader changes.
  Future<List<AyaTimingModel>> getTimings(
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

/// Pure domain helper that transforms [SurahPlayParams] into a scheduled plan of [_PlaybackItem]s.
class _SurahPlaybackPlanBuilder {
  static List<_PlaybackItem> buildPlan(SurahPlayParams params) {
    final List<_PlaybackItem> plan = [];

    for (int section = 0; section < params.sectionRepeatCount; section++) {
      for (
        int surah = params.startSurahNumber;
        surah <= params.endSurahNumber;
        surah++
      ) {
        final range = _calculateAyahRange(surah, params);
        _addItemsForSurah(
          plan,
          surahNumber: surah,
          range: range,
          params: params,
          currentSectionRepeat: section + 1,
          totalSectionRepeats: params.sectionRepeatCount,
        );
      }
    }

    return plan;
  }

  static ({int startAya, int endAya}) _calculateAyahRange(
    int surahNumber,
    SurahPlayParams params,
  ) {
    final int totalAyahs = SUR[surahNumber - 1].versesCount;

    if (params.startSurahNumber == params.endSurahNumber) {
      return (startAya: params.startAya, endAya: params.endAya);
    } else if (surahNumber == params.startSurahNumber) {
      return (startAya: params.startAya, endAya: totalAyahs);
    } else if (surahNumber == params.endSurahNumber) {
      return (startAya: 1, endAya: params.endAya);
    } else {
      return (startAya: 1, endAya: totalAyahs);
    }
  }

  static void _addItemsForSurah(
    List<_PlaybackItem> plan, {
    required int surahNumber,
    required ({int startAya, int endAya}) range,
    required SurahPlayParams params,
    required int currentSectionRepeat,
    required int totalSectionRepeats,
  }) {
    if (params.ayaRepeatCount == 1) {
      plan.add(
        _PlaybackItem(
          reader: params.reader,
          surahNumber: surahNumber,
          startAya: range.startAya,
          endAya: range.endAya,
          currentAyaRepeat: 1,
          totalAyaRepeats: 1,
          currentSectionRepeat: currentSectionRepeat,
          totalSectionRepeats: totalSectionRepeats,
        ),
      );
    } else {
      for (int aya = range.startAya; aya <= range.endAya; aya++) {
        for (int repeat = 0; repeat < params.ayaRepeatCount; repeat++) {
          plan.add(
            _PlaybackItem(
              reader: params.reader,
              surahNumber: surahNumber,
              startAya: aya,
              endAya: aya,
              currentAyaRepeat: repeat + 1,
              totalAyaRepeats: params.ayaRepeatCount,
              currentSectionRepeat: currentSectionRepeat,
              totalSectionRepeats: totalSectionRepeats,
            ),
          );
        }
      }
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

  // --- State Tracking ---
  SurahPlayerState _lastState = SurahPlayerState.idel;
  static bool _permissionsRequested = false;

  // --- Sliding Window Queue State ---
  List<_PlaybackItem> _playbackPlan = [];
  int _currentPlanIndex = -1;
  int _nextUnqueuedPlanIndex = 0;
  bool _isQueueUpdating = false;

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
    _initListeners();
  }

  void _initListeners() {
    _player.playerStateStream.listen(_handlePlayerStateChange);

    // Sliding window queue advancement listener:
    // When track 0 finishes and track 1 begins playing, index emits 1.
    // We drop track 0 and append the next scheduled track.
    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == 1) {
        _advanceSlidingWindow();
      }
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
    await _clearAndStopPlayback();
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
      _playbackPlan = _SurahPlaybackPlanBuilder.buildPlan(params);

      if (_playbackPlan.isEmpty) {
        _emit(SurahPlayerState.idel);
        return;
      }

      await _loadPlanWindow(0);
    } catch (e) {
      await _clearAndStopPlayback();
      if (e is Failure) {
        rethrow;
      } else {
        throw Failure.fromException(e);
      }
    }
  }

  /// Populates the 3-item sliding audio window starting at [targetIndex].
  Future<void> _loadPlanWindow(int targetIndex) async {
    if (targetIndex < 0 || targetIndex >= _playbackPlan.length) return;

    _isQueueUpdating = true;
    _emit(SurahPlayerState.loading);

    try {
      await _player.stop();
      _currentPlanIndex = targetIndex;
      _nextUnqueuedPlanIndex = targetIndex;

      final initialSources = <AudioSource>[];
      while (initialSources.length < 3 &&
          _nextUnqueuedPlanIndex < _playbackPlan.length) {
        final source = await _createAudioSource(
          _playbackPlan[_nextUnqueuedPlanIndex],
        );
        initialSources.add(source);
        _nextUnqueuedPlanIndex++;
      }

      if (initialSources.isNotEmpty) {
        final currentItem = _playbackPlan[_currentPlanIndex];
        mediaItem.add(_buildMediaMetadata(currentItem));

        await _player.setAudioSources(initialSources, initialIndex: 0);
        _player.play();
      }
    } finally {
      _isQueueUpdating = false;
      _syncBroadcastState();
    }
  }

  /// Advances the sliding window when a track completes.
  Future<void> _advanceSlidingWindow() async {
    if (_isQueueUpdating) return;
    _isQueueUpdating = true;

    try {
      _currentPlanIndex++;
      if (_currentPlanIndex < _playbackPlan.length) {
        final currentItem = _playbackPlan[_currentPlanIndex];
        mediaItem.add(_buildMediaMetadata(currentItem));
      }

      // Remove completed item from playlist head
      await _player.removeAudioSourceAt(0);

      // Append next item to playlist tail
      if (_nextUnqueuedPlanIndex < _playbackPlan.length) {
        final source = await _createAudioSource(
          _playbackPlan[_nextUnqueuedPlanIndex],
        );
        _nextUnqueuedPlanIndex++;
        await _player.addAudioSource(source);
      }
    } finally {
      _isQueueUpdating = false;
      _syncBroadcastState();
    }
  }

  /// Unified teardown routine (DRY): stops player, resets queue state, and clears notification.
  Future<void> _clearAndStopPlayback() async {
    _resetPlanState();
    mediaItem.add(null);
    await _player.stop();
    _emit(SurahPlayerState.idel);
    _broadcastPlaybackState(AudioProcessingState.idle, false);
  }

  void _resetPlanState() {
    _playbackPlan = [];
    _currentPlanIndex = -1;
    _nextUnqueuedPlanIndex = 0;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // State Mapping & System Notification Synchronization
  // ───────────────────────────────────────────────────────────────────────────

  void _handlePlayerStateChange(PlayerState playerState) {
    switch (playerState.processingState) {
      case ProcessingState.idle:
        if (_playbackPlan.isEmpty) {
          _clearAndStopPlayback();
        }
        break;

      case ProcessingState.loading:
        _emit(SurahPlayerState.loading);
        _broadcastPlaybackState(AudioProcessingState.loading, false);
        break;

      case ProcessingState.buffering:
        _emit(SurahPlayerState.loading);
        _broadcastPlaybackState(
          AudioProcessingState.buffering,
          playerState.playing,
        );
        break;

      case ProcessingState.ready:
        final bool isPlaying = playerState.playing;
        _emit(isPlaying ? SurahPlayerState.play : SurahPlayerState.pause);
        _broadcastPlaybackState(AudioProcessingState.ready, isPlaying);
        break;

      case ProcessingState.completed:
        _clearAndStopPlayback();
        break;
    }
  }

  void _syncBroadcastState() {
    final AudioProcessingState processing = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
    _broadcastPlaybackState(processing, _player.playing);
  }

  void _broadcastPlaybackState(
    AudioProcessingState processingState,
    bool playing,
  ) {
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

  MediaItem _buildMediaMetadata(_PlaybackItem item, {String? customId}) {
    final String surahName = SUR[item.surahNumber - 1].name;
    final String ayaInfo = item.startAya == item.endAya
        ? 'آية ${item.startAya}'
        : 'آيات ${item.startAya}-${item.endAya}';

    final String title = 'سورة $surahName ($ayaInfo)';

    final List<String> details = [];
    if (item.totalAyaRepeats > 1) {
      details.add('تكرار الآية: ${item.currentAyaRepeat}/${item.totalAyaRepeats}');
    }
    if (item.totalSectionRepeats > 1) {
      details.add('تكرار المقطع: ${item.currentSectionRepeat}/${item.totalSectionRepeats}');
    }
    if (details.isEmpty && item.reader.name.isNotEmpty) {
      details.add(item.reader.name);
    }

    final String subtitle = details.isNotEmpty
        ? details.join(' • ')
        : 'Tahfez';

    return MediaItem(
      id: customId ??
          '${item.surahNumber}_${item.startAya}_${item.currentAyaRepeat}_${item.currentSectionRepeat}',
      title: title,
      artist: subtitle,
      album: item.reader.name.isNotEmpty ? item.reader.name : 'Tahfez',
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper Utilities & Audio Sources
  // ───────────────────────────────────────────────────────────────────────────

  Future<AudioSource> _createAudioSource(_PlaybackItem item) async {
    final timings = await _timingsManager.getTimings(
      item.surahNumber,
      item.reader,
    );

    final int startMs = timings[item.startAya - 1].startTime;
    final int endMs = timings[item.endAya - 1].endTime;

    final uri = await QuranAudioResolver.playbackUri(
      item.reader,
      item.surahNumber,
    );

    return ClippingAudioSource(
      child: AudioSource.uri(uri),
      start: Duration(milliseconds: startMs),
      end: Duration(milliseconds: endMs),
      tag: _buildMediaMetadata(item, customId: uri.toString()),
    );
  }

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

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_timing_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';
import '../../domain/surah_player.dart';

/// Lightweight metadata for a single scheduled playback clip.
class _PlaybackItem {
  final ReaderModel reader;
  final int surahNumber;
  final int startAya;
  final int endAya;

  const _PlaybackItem({
    required this.reader,
    required this.surahNumber,
    required this.startAya,
    required this.endAya,
  });
}

class SurahPlayerJustAudioImpl extends BaseAudioHandler implements SurahPlayer {
  final StreamController<SurahPlayerState> _stateController =
      StreamController<SurahPlayerState>.broadcast();

  final AudioPlayer _player = AudioPlayer();
  final SurahAPI _api = SurahAPI();

  /// Timings cache per reader ID. Cleared when selected reader changes.
  final Map<int, List<AyaTimingModel>> _surahTimingsCache = {};
  int? _cachedReaderId;

  /// The lightweight playback plan (metadata for scheduled clips).
  List<_PlaybackItem> _playbackPlan = [];

  /// Current playing item index in `_playbackPlan`.
  int _currentPlanIndex = -1;

  /// Index of the next item to be queued into the sliding window playlist.
  int _nextUnqueuedPlanIndex = 0;

  /// Flag preventing concurrent sliding window updates.
  bool _isQueueUpdating = false;

  StreamSubscription? _currentIndexSub;

  static SurahPlayerJustAudioImpl? _instance;
  static SurahPlayerJustAudioImpl get instance {
    if (_instance == null) {
      throw Exception(
        'SurahPlayerJustAudioImpl not initialized, Call `SurahPlayerJustAudioImpl.init()` in main function before `runApp()` function',
      );
    }
    return _instance!;
  }

  static Future<void> init() async {
    _instance = await AudioService.init(
      builder: () => SurahPlayerJustAudioImpl._(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'tahfez.allam.labs',
        androidNotificationChannelName: 'Quran Playback',
        androidStopForegroundOnPause: false,
      ),
    );
  }

  SurahPlayerJustAudioImpl._() {
    _player.playerStateStream.listen(_handlePlayerStateChange);

    // Sliding window listener:
    // When track 0 finishes and track 1 begins, currentIndexStream emits 1.
    // We remove track 0 and queue the next item.
    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == 1) {
        _advanceSlidingWindow();
      }
    });
  }

  /// Maps just_audio player state changes to SurahPlayerState.
  void _handlePlayerStateChange(PlayerState playerState) {
    switch (playerState.processingState) {
      case ProcessingState.idle:
        if (_playbackPlan.isEmpty) {
          _stateController.add(SurahPlayerState.idel);
          _broadcastPlaybackState(AudioProcessingState.idle, false);
        }
        break;
      case ProcessingState.loading:
        _stateController.add(SurahPlayerState.loading);
        _broadcastPlaybackState(AudioProcessingState.loading, false);
        break;
      case ProcessingState.buffering:
        _stateController.add(SurahPlayerState.loading);
        _broadcastPlaybackState(
          AudioProcessingState.buffering,
          playerState.playing,
        );
        break;
      case ProcessingState.ready:
        if (playerState.playing) {
          _stateController.add(SurahPlayerState.play);
        } else if (!_isQueueUpdating) {
          _stateController.add(SurahPlayerState.pause);
        }
        _broadcastPlaybackState(
          AudioProcessingState.ready,
          playerState.playing,
        );
        break;
      case ProcessingState.completed:
        _onPlaybackCompleted();
        break;
    }
  }

  /// Advances the 3-item sliding window when a track finishes.
  Future<void> _advanceSlidingWindow() async {
    if (_isQueueUpdating) return;
    _isQueueUpdating = true;

    try {
      _currentPlanIndex++;
      if (_currentPlanIndex < _playbackPlan.length) {
        final currentItem = _playbackPlan[_currentPlanIndex];
        mediaItem.add(_createMediaMetadata(currentItem.surahNumber));
      }

      // Remove completed item from top of playlist
      await _player.removeAudioSourceAt(0);

      // Append next item to tail of playlist
      if (_nextUnqueuedPlanIndex < _playbackPlan.length) {
        final source = await _createAudioSource(
          _playbackPlan[_nextUnqueuedPlanIndex],
        );
        _nextUnqueuedPlanIndex++;
        await _player.addAudioSource(source);
      }
    } finally {
      _isQueueUpdating = false;
    }
  }

  /// Broadcasts playback state to notification and system controllers.
  void _broadcastPlaybackState(
    AudioProcessingState processingState,
    bool playing,
  ) {
    playbackState.add(
      PlaybackState(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  /// Helper creating system notification metadata.
  MediaItem _createMediaMetadata(int surahNumber, {String? customId}) {
    return MediaItem(
      id: customId ?? surahNumber.toString(),
      title: SUR[surahNumber - 1].name,
      album: 'Tahfez',
    );
  }

  /// Resets internal plan pointers.
  void _resetPlanState() {
    _playbackPlan = [];
    _currentPlanIndex = -1;
    _nextUnqueuedPlanIndex = 0;
  }

  // ──────────────────────────────────────────────────────────
  // BaseAudioHandler overrides
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> play([SurahPlayParams? params]) async {
    if (params != null) {
      await _startPlayback(params);
    }else{
      _player.play();
    }
  }

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async {
    _resetPlanState();
    await _player.stop();
    _broadcastPlaybackState(AudioProcessingState.idle, false);
  }

  @override
  Future<void> resume() => _player.play();

  // ──────────────────────────────────────────────────────────
  // Playback Window Management
  // ──────────────────────────────────────────────────────────

  /// Starts playback from params.
  Future<void> _startPlayback(SurahPlayParams params) async {
    _stateController.add(SurahPlayerState.loading);
    await _player.stop();

    try {
      _playbackPlan = _generatePlaybackPlan(params);

      if (_playbackPlan.isEmpty) {
        _stateController.add(SurahPlayerState.idel);
        return;
      }

      await _loadPlanWindow(0);
    } catch (e) {
      _resetPlanState();
      _stateController.add(SurahPlayerState.idel);
      if (e is Failure) {
        rethrow;
      } else {
        throw Failure.fromException(e);
      }
    }
  }

  /// Loads/resets the 3-item sliding window starting at `targetIndex`.
  Future<void> _loadPlanWindow(int targetIndex) async {
    if (targetIndex < 0 || targetIndex >= _playbackPlan.length) return;
    _isQueueUpdating = true;
    _stateController.add(SurahPlayerState.loading);
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
        mediaItem.add(_createMediaMetadata(currentItem.surahNumber));

        await _player.setAudioSources(initialSources, initialIndex: 0);
        _player.play();
      }
    } finally {
      _isQueueUpdating = false;
    }
  }

  /// Fetches timings for a single surah on demand, caching it per reader.
  Future<List<AyaTimingModel>> _getSurahTimings(
    int surahNumber,
    ReaderModel reader,
  ) async {
    if (_cachedReaderId != reader.id) {
      _surahTimingsCache.clear();
      _cachedReaderId = reader.id;
    }

    if (_surahTimingsCache.containsKey(surahNumber)) {
      return _surahTimingsCache[surahNumber]!;
    }

    try {
      final timings = await _api.getTiming(surahNumber, reader.id);
      _surahTimingsCache[surahNumber] = timings;
      return timings;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// Creates a ClippingAudioSource for a plan item.
  Future<AudioSource> _createAudioSource(_PlaybackItem item) async {
    final timings = await _getSurahTimings(item.surahNumber, item.reader);

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
      tag: _createMediaMetadata(item.surahNumber, customId: uri.toString()),
    );
  }

  void _onPlaybackCompleted() {
    _resetPlanState();
    _stateController.add(SurahPlayerState.idel);
    _broadcastPlaybackState(AudioProcessingState.completed, false);
  }

  /// Generates the playback plan synchronously.
  List<_PlaybackItem> _generatePlaybackPlan(SurahPlayParams params) {
    if (_cachedReaderId != params.reader.id) {
      _surahTimingsCache.clear();
      _cachedReaderId = params.reader.id;
    }

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
        );
      }
    }

    return plan;
  }

  /// Calculates start/end Ayah numbers for a Surah within the requested play range.
  ({int startAya, int endAya}) _calculateAyahRange(
    int surahNumber,
    SurahPlayParams params,
  ) {
    final int surahTotalAyahs = SUR[surahNumber - 1].versesCount;

    if (params.startSurahNumber == params.endSurahNumber) {
      return (startAya: params.startAya, endAya: params.endAya);
    } else if (surahNumber == params.startSurahNumber) {
      return (startAya: params.startAya, endAya: surahTotalAyahs);
    } else if (surahNumber == params.endSurahNumber) {
      return (startAya: 1, endAya: params.endAya);
    } else {
      return (startAya: 1, endAya: surahTotalAyahs);
    }
  }

  /// Appends `_PlaybackItem` objects for a Surah according to repetition settings.
  void _addItemsForSurah(
    List<_PlaybackItem> plan, {
    required int surahNumber,
    required ({int startAya, int endAya}) range,
    required SurahPlayParams params,
  }) {
    if (params.ayaRepeatCount == 1) {
      plan.add(
        _PlaybackItem(
          reader: params.reader,
          surahNumber: surahNumber,
          startAya: range.startAya,
          endAya: range.endAya,
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
            ),
          );
        }
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _currentIndexSub?.cancel();
    await _player.dispose();
  }

  @override
  Stream<SurahPlayerState> get state => _stateController.stream;
}

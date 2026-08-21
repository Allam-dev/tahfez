import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_timing_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';
import '../../domain/surah_player.dart';

/// Lightweight metadata for a single playback item.
/// No native resources allocated — just timing info (~50 bytes each).
class _PlaybackItem {
  final ReaderModel reader;
  final int surahNumber;
  final int startMs;
  final int endMs;

  const _PlaybackItem({
    required this.reader,
    required this.surahNumber,
    required this.startMs,
    required this.endMs,
  });
}

class SurahPlayerJustAudioImpl extends BaseAudioHandler implements SurahPlayer {
  final StreamController<SurahPlayerState> _stateController =
      StreamController<SurahPlayerState>.broadcast();

  final AudioPlayer _player = AudioPlayer();
  final SurahAPI _api = SurahAPI();

  /// The lightweight playback plan — metadata for every scheduled clip.
  List<_PlaybackItem> _playbackPlan = [];

  /// Current playing index in `_playbackPlan`.
  int _currentPlanIndex = -1;

  /// Index of the next unqueued item in `_playbackPlan`.
  int _nextPlanIndex = 0;

  bool _isAdvancing = false;
  StreamSubscription? _currentIndexSub;

  static SurahPlayerJustAudioImpl? _instance;
  static SurahPlayerJustAudioImpl get instance {
    if (_instance == null) {
      throw Exception(
        'SurahPlayerJustAudioImpl not initialized, Call `SurahPlayerJustAudioImpl.init()` in your main function before `runApp()` function',
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
    _player.playerStateStream.listen((playerState) {
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
          } else if (!_isAdvancing) {
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
    });

    // Sliding window: when item 0 finishes and item 1 starts playing,
    // currentIndexStream emits 1. We remove item 0 and push item 3 to the end.
    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == 1) {
        _onItemFinishedAndAdvance();
      }
    });
  }

  /// Advances the sliding window when an item in the playlist finishes.
  Future<void> _onItemFinishedAndAdvance() async {
    if (_isAdvancing) return;
    _isAdvancing = true;

    try {
      _currentPlanIndex++;
      if (_currentPlanIndex < _playbackPlan.length) {
        final currentItem = _playbackPlan[_currentPlanIndex];
        mediaItem.add(
          MediaItem(
            id: currentItem.surahNumber.toString(),
            title: SUR[currentItem.surahNumber - 1].name,
            album: 'Tahfez',
          ),
        );
      }

      // Drop finished item from start of playlist
      await _player.removeAudioSourceAt(0);

      // Append next plan item to end of playlist
      if (_nextPlanIndex < _playbackPlan.length) {
        final source = await _createAudioSource(_playbackPlan[_nextPlanIndex]);
        _nextPlanIndex++;
        await _player.addAudioSource(source);
      }
    } finally {
      _isAdvancing = false;
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
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // BaseAudioHandler overrides
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> play([SurahPlayParams? params]) async {
    if (params != null) {
      await _startPlayback(params);
    } else {
      _player.play();
    }
  }

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async {
    _playbackPlan = [];
    _currentPlanIndex = -1;
    _nextPlanIndex = 0;
    await _player.stop();
    _broadcastPlaybackState(AudioProcessingState.idle, false);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentPlanIndex + 1 < _playbackPlan.length) {
      await _loadPlanIndex(_currentPlanIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentPlanIndex > 0) {
      await _loadPlanIndex(_currentPlanIndex - 1);
    }
  }

  @override
  Future<void> seek(Duration position) async => _player.seek(position);

  @override
  Future<void> resume() => _player.play();

  // ──────────────────────────────────────────────────────────
  // Playback Window Management
  // ──────────────────────────────────────────────────────────

  /// Starts playback from params.
  Future<void> _startPlayback(SurahPlayParams params) async {
    _stateController.add(SurahPlayerState.loading);
    await _player.stop();

    _playbackPlan = await _generatePlaybackPlan(params);

    if (_playbackPlan.isEmpty) {
      _stateController.add(SurahPlayerState.idel);
      return;
    }

    await _loadPlanIndex(0);
  }

  /// Loads/resets the sliding window starting at `targetIndex` in `_playbackPlan`.
  Future<void> _loadPlanIndex(int targetIndex) async {
    if (targetIndex < 0 || targetIndex >= _playbackPlan.length) return;
    _isAdvancing = true;
    _stateController.add(SurahPlayerState.loading);
    try {
      await _player.stop();
      _currentPlanIndex = targetIndex;
      _nextPlanIndex = targetIndex;

      final initialSources = <AudioSource>[];
      while (
          initialSources.length < 3 && _nextPlanIndex < _playbackPlan.length) {
        final source = await _createAudioSource(_playbackPlan[_nextPlanIndex]);
        initialSources.add(source);
        _nextPlanIndex++;
      }

      if (initialSources.isNotEmpty) {
        final currentItem = _playbackPlan[_currentPlanIndex];
        mediaItem.add(
          MediaItem(
            id: currentItem.surahNumber.toString(),
            title: SUR[currentItem.surahNumber - 1].name,
            album: 'Tahfez',
          ),
        );

        await _player.setAudioSources(
          initialSources,
          initialIndex: 0,
        );
        _player.play();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  /// Creates a ClippingAudioSource for a plan item.
  /// Resolves URI locally (file://) if downloaded, or remotely (https://) if online.
  Future<AudioSource> _createAudioSource(_PlaybackItem item) async {
    final uri = await QuranAudioResolver.playbackUri(
      item.reader,
      item.surahNumber,
    );
    return ClippingAudioSource(
      child: AudioSource.uri(uri),
      start: Duration(milliseconds: item.startMs),
      end: Duration(milliseconds: item.endMs),
      tag: MediaItem(
        id: uri.toString(),
        title: SUR[item.surahNumber - 1].name,
        album: 'Tahfez',
      ),
    );
  }

  void _onPlaybackCompleted() {
    _playbackPlan = [];
    _currentPlanIndex = -1;
    _nextPlanIndex = 0;
    _stateController.add(SurahPlayerState.idel);
    _broadcastPlaybackState(AudioProcessingState.completed, false);
  }

  /// Generates the lightweight playback plan.
  Future<List<_PlaybackItem>> _generatePlaybackPlan(
    SurahPlayParams params,
  ) async {
    final List<_PlaybackItem> plan = [];

    for (int section = 0; section < params.sectionRepeatCount; section++) {
      for (
        int surah = params.startSurahNumber;
        surah <= params.endSurahNumber;
        surah++
      ) {
        final List<AyaTimingModel> timings = await _api.getTiming(
          surah,
          params.reader.id,
        );
        if (timings.isEmpty) continue;

        final int startAya;
        final int endAya;

        if (params.startSurahNumber == params.endSurahNumber) {
          startAya = params.startAya;
          endAya = params.endAya;
        } else if (surah == params.startSurahNumber) {
          startAya = params.startAya;
          endAya = timings.length;
        } else if (surah == params.endSurahNumber) {
          startAya = 1;
          endAya = params.endAya;
        } else {
          startAya = 1;
          endAya = timings.length;
        }

        if (params.ayaRepeatCount == 1) {
          // No per-ayah repetition: play the whole range as one clip
          plan.add(
            _PlaybackItem(
              reader: params.reader,
              surahNumber: surah,
              startMs: timings[startAya - 1].startTime,
              endMs: timings[endAya - 1].endTime,
            ),
          );
        } else {
          // Per-ayah repetition: each ayah repeated N times
          for (int aya = startAya; aya <= endAya; aya++) {
            for (int repeat = 0; repeat < params.ayaRepeatCount; repeat++) {
              plan.add(
                _PlaybackItem(
                  reader: params.reader,
                  surahNumber: surah,
                  startMs: timings[aya - 1].startTime,
                  endMs: timings[aya - 1].endTime,
                ),
              );
            }
          }
        }
      }
    }

    return plan;
  }

  @override
  Future<void> dispose() async {
    await _currentIndexSub?.cancel();
    await _player.dispose();
  }

  @override
  Stream<SurahPlayerState> get state => _stateController.stream;
}

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_timing_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import '../../domain/surah_player.dart';

/// Lightweight metadata for a single playback item.
/// No native resources allocated — just timing info (~50 bytes each).
class _PlaybackItem {
  final String surahUrl;
  final int surahNumber;
  final int startMs;
  final int endMs;

  const _PlaybackItem({
    required this.surahUrl,
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

  /// The lightweight playback plan — just metadata, no native AudioSource objects.
  List<_PlaybackItem> _playbackPlan = [];
  int _currentIndex = -1;
  bool _isAdvancing = false;

  static SurahPlayerJustAudioImpl? _instance;
  static SurahPlayerJustAudioImpl get instance {
    if (_instance == null) {
      throw Exception('SurahPlayerJustAudioImpl not initialized, Call `SurahPlayerJustAudioImpl.init()` in your main function before `runApp()` function');
    }
    return _instance!;
  }

  static Future<void> init() async {
    _instance = await AudioService.init(
    builder: () => SurahPlayerJustAudioImpl._(),
    config: AudioServiceConfig(
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
          _advanceToNext();
          break;
      }
    });
  }

  /// Broadcasts the current playback state to the system notification,
  /// lock screen, and any connected media controllers.
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
  // BaseAudioHandler overrides (notification / lock screen / headset)
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> play([SurahPlayParams? params]) async {
    if (params != null) {
      await _startPlayback(params);
    } else {
      // Resume — called from notification play button
      _player.play();
    }
  }

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async {
    _playbackPlan = [];
    _currentIndex = -1;
    await _player.stop();
    _broadcastPlaybackState(AudioProcessingState.idle, false);
  }

  @override
  Future<void> skipToNext() async => _advanceToNext();

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex -= 2; // will be incremented in _advanceToNext
      await _advanceToNext();
    }
  }

  @override
  Future<void> seek(Duration position) async => _player.seek(position);

  // ──────────────────────────────────────────────────────────
  // SurahPlayer interface implementation
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> resume() => _player.play();

  /// Starts playback with the given params (called from the cubit).
  Future<void> _startPlayback(SurahPlayParams params) async {
    _stateController.add(SurahPlayerState.loading);
    await _player.stop();

    // Generate lightweight playback plan (just metadata, no AudioSource objects)
    // Even 124,720 items (whole Quran × 20 repeats) ≈ ~6MB Dart heap — no OOM
    _playbackPlan = await _generatePlaybackPlan(params);
    _currentIndex = -1;

    if (_playbackPlan.isEmpty) {
      _stateController.add(SurahPlayerState.idel);
      return;
    }

    await _advanceToNext();
  }

  /// Advances to the next item in the playback plan.
  /// Called when the current clip completes or when starting playback.
  Future<void> _advanceToNext() async {
    if (_isAdvancing) return;
    _isAdvancing = true;

    try {
      _currentIndex++;
      if (_currentIndex < _playbackPlan.length) {
        final item = _playbackPlan[_currentIndex];
        await _player.setAudioSource(
          ClippingAudioSource(
            child: AudioSource.uri(Uri.parse(item.surahUrl)),
            start: Duration(milliseconds: item.startMs),
            end: Duration(milliseconds: item.endMs),
          ),
        );

        // Update notification with current item info
        mediaItem.add(
          MediaItem(
            id: item.surahUrl,
            title: SUR[item.surahNumber - 1].name,
            album: 'Tahfez',
          ),
        );

        // Check if we were stopped during setAudioSource
        if (_playbackPlan.isNotEmpty) {
          _player.play();
        }
      } else {
        // All items have been played
        _playbackPlan = [];
        _currentIndex = -1;
        _stateController.add(SurahPlayerState.idel);
        _broadcastPlaybackState(AudioProcessingState.completed, false);
      }
    } finally {
      _isAdvancing = false;
    }
  }

  /// Generates a lightweight playback plan from the params.
  /// Each item is just metadata (~50 bytes), not a native AudioSource.
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

        final fileName = surah.toString().padLeft(3, '0');
        final surahUrl = "${params.reader.downloadUrl}$fileName.mp3";

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
              surahUrl: surahUrl,
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
                  surahUrl: surahUrl,
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
  Future<void> dispose() => _player.dispose();

  @override
  Stream<SurahPlayerState> get state => _stateController.stream;
}

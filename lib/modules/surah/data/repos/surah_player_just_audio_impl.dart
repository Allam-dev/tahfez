import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_timing_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import '../../domain/surah_player.dart';

class SurahPlayerJustAudioImpl implements SurahPlayer {
  SurahPlayerJustAudioImpl._() {
    _playingSubscription = _player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          _stateController.add(SurahPlayerState.idel);
          break;
        case ProcessingState.loading:
          _stateController.add(SurahPlayerState.loading);
          break;
        case ProcessingState.buffering:
          _stateController.add(SurahPlayerState.loading);
          break;
        case ProcessingState.ready:
          if (state.playing) {
            _stateController.add(SurahPlayerState.play);
          } else {
            _stateController.add(SurahPlayerState.pause);
          }
          break;
        case ProcessingState.completed:
          _stateController.add(SurahPlayerState.idel);
          break;
      }
    });
  }
  
  static SurahPlayerJustAudioImpl instance = SurahPlayerJustAudioImpl._();
  late final StreamSubscription<PlayerState> _playingSubscription;
  final AudioPlayer _player = AudioPlayer();
  final StreamController<SurahPlayerState> _stateController =
      StreamController<SurahPlayerState>.broadcast();
  final SurahAPI _api = SurahAPI();

  @override
  Future<void> play(SurahPlayParams params) async {
    _stateController.add(SurahPlayerState.loading);
    await _player.stop();
    final List<AudioSource> sources = await _generateSectionAudioSources(
      params,
    );
    await _player.setAudioSources(sources, preload: false);
    await _player.play();
  }

  Future<List<AudioSource>> _generateSectionAudioSources(
    SurahPlayParams params,
  ) async {
    final List<AudioSource> sources = [];

    for (
      int surah = params.startSurahNumber;
      surah <= params.endSurahNumber;
      surah++
    ) {
      final List<AyaTimingModel> timings = await _api.getTiming(
        surah,
        params.reader.id,
      );
      if (timings.isEmpty) return sources;
      final fileName = surah.toString().padLeft(3, '0');
      final surahUrl = "${params.reader.downloadUrl}$fileName.mp3";
      // same surah
      if (params.startSurahNumber == params.endSurahNumber) {
        sources.addAll(
          _generateSurahAudioSources(
            surahNumber: surah,
            startAya: params.startAya,
            endAya: params.endAya,
            ayaRepeatCount: params.ayaRepeatCount,
            surahUrl: surahUrl,
            timings: timings,
          ),
        );
      }
      // first surah
      else if (surah == params.startSurahNumber) {
        sources.addAll(
          _generateSurahAudioSources(
            surahNumber: surah,
            startAya: params.startAya,
            endAya: timings.length,
            ayaRepeatCount: params.ayaRepeatCount,
            surahUrl: surahUrl,
            timings: timings,
          ),
        );
      }
      // last surah
      else if (surah == params.endSurahNumber) {
        sources.addAll(
          _generateSurahAudioSources(
            surahNumber: surah,
            startAya: 1,
            endAya: params.endAya,
            ayaRepeatCount: params.ayaRepeatCount,
            surahUrl: surahUrl,
            timings: timings,
          ),
        );
      }
      // middle surah
      else {
        sources.addAll(
          _generateSurahAudioSources(
            surahNumber: surah,
            startAya: 1,
            endAya: timings.length,
            ayaRepeatCount: params.ayaRepeatCount,
            surahUrl: surahUrl,
            timings: timings,
          ),
        );
      }
    }
    return List.generate(
      params.sectionRepeatCount * sources.length,
      (i) => sources[i % sources.length],
    );
  }

  List<AudioSource> _generateSurahAudioSources({
    required int surahNumber,
    required int startAya,
    required int endAya,
    required int ayaRepeatCount,
    required String surahUrl,
    required List<AyaTimingModel> timings,
  }) {
    final List<AudioSource> sources = [];
    // 1 aya repeation
    if (ayaRepeatCount == 1) {
      sources.add(
        ClippingAudioSource(
          child: AudioSource.uri(Uri.parse(surahUrl)),
          start: Duration(milliseconds: timings[startAya - 1].startTime),
          end: Duration(milliseconds: timings[endAya - 1].endTime),
        ),
      );
    }
    // n aya
    else {
      for (int aya = startAya; aya <= endAya; aya++) {
        sources.addAll(
          List.filled(
            ayaRepeatCount,
            ClippingAudioSource(
              child: AudioSource.uri(Uri.parse(surahUrl)),
              start: Duration(milliseconds: timings[aya - 1].startTime),
              end: Duration(milliseconds: timings[aya - 1].endTime),
            ),
          ),
        );
      }
    }
    return sources;
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _playingSubscription.cancel();
    await _stateController.close();
  }

  @override
  Stream<SurahPlayerState> get state => _stateController.stream;
}

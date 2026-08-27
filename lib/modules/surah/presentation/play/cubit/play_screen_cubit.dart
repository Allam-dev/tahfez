import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'play_screen_state.dart';

class PlayScreenCubit extends Cubit<PlayScreenState> {
  static const String _lastParamsCacheKey = 'last_play_params';

  final SurahPlayer _surahRepo;
  late final SurahPlayParams playParams;
  late final StreamSubscription<SurahPlayerState>
  _playerStateStreamSubscription;
  PlayScreenCubit(this._surahRepo) : super(PlayScreenInitialState()) {
    playParams = _loadCachedParams() ?? _defaultPlayParams();
    _playerStateStreamSubscription = _surahRepo.state.listen((state) {
      switch (state) {
        case SurahPlayerState.idel:
          emit(PlayScreenInitialState());
          break;
        case SurahPlayerState.loading:
          emit(PlayScreenLoadingState());
          break;
        case SurahPlayerState.play:
          emit(PlayScreenPlayingState());
          break;
        case SurahPlayerState.pause:
          emit(PlayScreenPauseState());
          break;
      }
    });
  }
  SurahPlayParams _defaultPlayParams() => SurahPlayParams(
    startSurahNumber: 1,
    endSurahNumber: 1,
    reader: ReaderModel.fake(),
    startAya: 1,
    endAya: 7,
  );

  /// Restores the last used playback settings (reader + range) so the UI
  /// prefills them even after the app process was killed and restarted.
  SurahPlayParams? _loadCachedParams() {
    try {
      final dynamic raw = HydratedBloc.storage.read(_lastParamsCacheKey);
      if (raw is! Map) return null;
      final reader = ReaderModel(
        id: raw['readerId'] as int? ?? 0,
        name: raw['readerName'] as String? ?? '',
        rewaya: raw['readerRewaya'] as String? ?? '',
        downloadUrl: raw['readerUrl'] as String? ?? '',
      );
      if (reader.id == 0) return null;
      return SurahPlayParams(
        reader: reader,
        startSurahNumber: raw['startSurahNumber'] as int? ?? 1,
        endSurahNumber: raw['endSurahNumber'] as int? ?? 1,
        startAya: raw['startAya'] as int? ?? 1,
        endAya: raw['endAya'] as int? ?? 7,
        ayaRepeatCount: raw['ayaRepeatCount'] as int? ?? 1,
        sectionRepeatCount: raw['sectionRepeatCount'] as int? ?? 1,
      );
    } catch (_) {
      return null;
    }
  }

  void _cacheLastParams(SurahPlayParams params) {
    try {
      HydratedBloc.storage.write(_lastParamsCacheKey, <String, dynamic>{
        'readerId': params.reader.id,
        'readerName': params.reader.name,
        'readerRewaya': params.reader.rewaya,
        'readerUrl': params.reader.downloadUrl,
        'startSurahNumber': params.startSurahNumber,
        'endSurahNumber': params.endSurahNumber,
        'startAya': params.startAya,
        'endAya': params.endAya,
        'ayaRepeatCount': params.ayaRepeatCount,
        'sectionRepeatCount': params.sectionRepeatCount,
      });
    } catch (_) {
      // Cache is a UX convenience; never let it break playback.
    }
  }

  Future<void> play() async {
    if (playParams.reader.id == 0) {
      emit(PlayScreenFailureState(Failure(message: LocaleKeys.selectReader)));
      return;
    }

    try {
      await _surahRepo.start(playParams);
      _cacheLastParams(playParams);
    } catch (e) {
      Log.error(e.toString());
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  Future<void> pause() async {
    try {
      _surahRepo.pause();
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  Future<void> resume() async {
    try {
      _surahRepo.resume();
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  Future<void> stop() async {
    try {
      _surahRepo.stop();
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  @override
  Future<void> close() async {
    await _playerStateStreamSubscription.cancel();
    // Do NOT dispose the player — it lives in the foreground service
    // and must persist even when the cubit/screen is closed.
    return super.close();
  }
}

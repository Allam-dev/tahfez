import 'dart:async';

import 'package:bloc/bloc.dart';
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
  final SurahPlayer _surahRepo;
  late final StreamSubscription<SurahPlayerState>
  _playerStateStreamSubscription;
  PlayScreenCubit(this._surahRepo) : super(PlayScreenInitialState()) {
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
  final SurahPlayParams playParams = SurahPlayParams(
    startSurahNumber: 1,
    endSurahNumber: 1,
    reader: ReaderModel.fake(),
    startAya: 1,
    endAya: 7,
  );

  Future<void> play() async {
    if (playParams.reader.id == 0) {
      emit(PlayScreenFailureState(Failure(message: LocaleKeys.selectReader)));
      return;
    }

    try {
      await _surahRepo.play(playParams);
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

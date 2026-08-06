import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'play_screen_state.dart';

class PlayScreenCubit extends Cubit<PlayScreenState> {
  final SurahPlayer _surahRepo;
  late final StreamSubscription<SurahPlayerState> _stateSubscription;
  PlayScreenCubit(this._surahRepo) : super(PlayScreenInitialState()) {
    _stateSubscription = _surahRepo.state.listen((state) {
      switch (state) {
        case SurahPlayerState.idel:
          emit(PlayScreenInitialState());
          break;
        case SurahPlayerState.play:
          emit(PlayScreenPlayingState());
          break;
        case SurahPlayerState.pause:
          emit(PlayScreenInitialState());
          break;
        case SurahPlayerState.loading:
          emit(PlayScreenLoadingState());
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
      emit(PlayScreenLoadingState());
      await _surahRepo.play(playParams);
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  Future<void> pause() async {
    try {
      await _surahRepo.pause();
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  Future<void> stop() async {
    try {
      await _surahRepo.stop();
    } catch (e) {
      emit(PlayScreenFailureState(Failure.fromException(e)));
    }
  }

  @override
  Future<void> close() async {
    await _surahRepo.dispose();
    await _stateSubscription.cancel();
    return super.close();
  }
}

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';

part 'play_settings_screen_state.dart';

class PlaySettingsScreenCubit extends HydratedCubit<PlaySettingsScreenState> {
  PlaySettingsScreenCubit()
    : super(
        PlaySettingsScreenState(
          playParams: SurahPlayParams(
            startSurahNumber: 1,
            endSurahNumber: 1,
            reader: ReaderModel.fake(),
            startAya: 1,
            endAya: 7,
          ),
        ),
      );

  void changeReader(ReaderModel reader) {
    state.playParams.reader = reader;
    emit(state.copyWith(status: PlaySettingsScreenStatus.readerChanged));
  }

  void changeStartSurah(int? surahNumber) {
    if (surahNumber == null) return;
    state.playParams.startSurahNumber = surahNumber;
    state.playParams.endSurahNumber = surahNumber;
    state.playParams.startAya = 1;
    state.playParams.endAya = SUR[surahNumber - 1].versesCount;
    emit(state.copyWith(status: PlaySettingsScreenStatus.startSurahChanged));
  }

  void changeStartAya(int? aya) {
    if (aya == null) return;
    state.playParams.startAya = aya;
    if (aya == SUR[state.playParams.startSurahNumber - 1].versesCount) {
      state.playParams.endSurahNumber = state.playParams.startSurahNumber + 1;
      state.playParams.endAya = 1;
    } else {
      state.playParams.endSurahNumber = state.playParams.startSurahNumber;
      state.playParams.endAya =
          SUR[state.playParams.startSurahNumber - 1].versesCount;
    }
    emit(state.copyWith(status: PlaySettingsScreenStatus.startAyaChanged));
  }

  void changeEndSurah(int? surahNumber) {
    if (surahNumber == null) return;
    state.playParams.endSurahNumber = surahNumber;
    state.playParams.endAya = SUR[surahNumber - 1].versesCount;
    emit(state.copyWith(status: PlaySettingsScreenStatus.endSurahChanged));
  }

  void changeEndAya(int? aya) {
    if (aya == null) return;
    state.playParams.endAya = aya;
    emit(state.copyWith(status: PlaySettingsScreenStatus.endAyaChanged));
  }

  void playAudio(bool? value) {
    if (value != null) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.switchChanged,
          playAudio: value,
          downloadWhilePlaying: value,
          downloadingOnly: false,
        ),
      );
    }
  }

  void downloadWhilePlaying(bool? value) {
    if (value != null) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.switchChanged,
          playAudio: true,
          downloadWhilePlaying: value,
          downloadingOnly: false,
        ),
      );
    }
  }

  void downloadOnly(bool? value) {
    if (value != null) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.switchChanged,
          playAudio: false,
          downloadWhilePlaying: false,
          downloadingOnly: value,
        ),
      );
    }
  }

  void incrementAyaRepetition() {
    state.playParams.ayaRepeatCount++;
    emit(state.copyWith(status: PlaySettingsScreenStatus.ayaRepetitionChanged));
  }

  void decrementAyaRepetition() {
    if (state.playParams.ayaRepeatCount > 1) {
      state.playParams.ayaRepeatCount--;
      emit(state.copyWith(status: PlaySettingsScreenStatus.ayaRepetitionChanged));
    }
  }

  void incrementSectionRepetition() {
    state.playParams.sectionRepeatCount++;
    emit(state.copyWith(status: PlaySettingsScreenStatus.sectionRepetitionChanged));
  }

  void decrementSectionRepetition() {
    if (state.playParams.sectionRepeatCount > 1) {
      state.playParams.sectionRepeatCount--;
      emit(state.copyWith(status: PlaySettingsScreenStatus.sectionRepetitionChanged));
    }
  }

  @override
  PlaySettingsScreenState? fromJson(Map<String, dynamic> json) {
    return PlaySettingsScreenState(
      playParams: SurahPlayParams.fromJson(json['play_params']),
      playAudio: json['play_audio'],
      downloadWhilePlaying: json['download_while_playing'],
      downloadingOnly: json['downloading_only'],
    );
  }

  @override
  Map<String, dynamic>? toJson(PlaySettingsScreenState state) {
    return {
      'play_params': state.playParams.toJson(),
      'play_audio': state.playAudio,
      'download_while_playing': state.downloadWhilePlaying,
      'downloading_only': state.downloadingOnly,
    };
  }
}

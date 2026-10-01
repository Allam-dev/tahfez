import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'play_settings_screen_state.dart';

class PlaySettingsScreenCubit extends HydratedCubit<PlaySettingsScreenState> {
  final SurahPlayer _player;
  final SurahDownloader _downloader;
  late StreamSubscription<SurahPlaybackInfo> _playbackSubscription;

  PlaySettingsScreenCubit(
    this._player,
    this._downloader, {
    SurahPlayParams? playParams,
  }) : super(
         PlaySettingsScreenState(
           playParams: SurahPlayParams(
             startSurahNumber: 1,
             endSurahNumber: 1,
             reader: ReaderModel.fake(),
             startAya: 1,
             endAya: 7,
           ),
         ),
       ) {
    _playbackSubscription = _player.status.listen((playbackInfo) {
      emit(
        state.copyWith(
          playbackInfo: playbackInfo,
          status: PlaySettingsScreenStatus.inital,
        ),
      );
    });
    if (playParams != null) {
      emit(
        state.copyWith(
          playParams: playParams,
          playAudio: true,
          downloadWhilePlaying: false,
          downloadingOnly: false,
        ),
      );
    }
  }

  void changeReader(ReaderModel reader) {
    state.playParams.reader = reader;
  }

  void changeStartSurah(int? surahNumber) {
    if (surahNumber == null || !state.playbackInfo.playerState.isIdel) return;
    state.playParams.startSurahNumber = surahNumber;
    state.playParams.endSurahNumber = surahNumber;
    state.playParams.startAya = 1;
    state.playParams.endAya = SUR[surahNumber - 1].versesCount;
    emit(state.copyWith(status: PlaySettingsScreenStatus.startSurahChanged));
  }

  void changeStartAya(int? aya) {
    if (aya == null || !state.playbackInfo.playerState.isIdel) return;
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
    if (surahNumber == null || !state.playbackInfo.playerState.isIdel) return;
    state.playParams.endSurahNumber = surahNumber;
    state.playParams.endAya = SUR[surahNumber - 1].versesCount;
    emit(state.copyWith(status: PlaySettingsScreenStatus.endSurahChanged));
  }

  void changeEndAya(int? aya) {
    if (aya == null || !state.playbackInfo.playerState.isIdel) return;
    state.playParams.endAya = aya;
    emit(state.copyWith(status: PlaySettingsScreenStatus.endAyaChanged));
  }

  void playAudio(bool? value) {
    if (value != null && state.playbackInfo.playerState.isIdel) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.switchChanged,
          playAudio: value,
          downloadWhilePlaying: value,
          downloadingOnly: !value,
        ),
      );
    }
  }

  void downloadWhilePlaying(bool? value) {
    if (value != null && state.playbackInfo.playerState.isIdel) {
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
    if (value != null && state.playbackInfo.playerState.isIdel) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.switchChanged,
          playAudio: !value,
          downloadWhilePlaying: !value,
          downloadingOnly: value,
        ),
      );
    }
  }

  void incrementAyaRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;
    state.playParams.ayaRepeatCount++;
    emit(state.copyWith(status: PlaySettingsScreenStatus.ayaRepetitionChanged));
  }

  void decrementAyaRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;
    if (state.playParams.ayaRepeatCount > 1) {
      state.playParams.ayaRepeatCount--;
      emit(
        state.copyWith(status: PlaySettingsScreenStatus.ayaRepetitionChanged),
      );
    }
  }

  void incrementSectionRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;

    state.playParams.sectionRepeatCount++;
    emit(
      state.copyWith(status: PlaySettingsScreenStatus.sectionRepetitionChanged),
    );
  }

  void decrementSectionRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;

    if (state.playParams.sectionRepeatCount > 1) {
      state.playParams.sectionRepeatCount--;
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.sectionRepetitionChanged,
        ),
      );
    }
  }

  void pause() {
    _player.pause();
  }

  void stop() {
    _player.stop();
  }

  void resume() {
    _player.resume();
  }

  void start() {
    if (state.playAudio) {
      _play();
    }

    if (state.downloadWhilePlaying || state.downloadingOnly) {
      _download();
    }
  }

  Future<void> _play() async {
    try {
      await _player.start(state.playParams);
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.error,
          failure: Failure.fromException(e),
        ),
      );
    }
  }

  Future<void> _download() async {
    try {
      await _downloader.downloadRange(
        state.playParams.reader,
        state.playParams.startSurahNumber,
        state.playParams.endSurahNumber,
      );
      emit(state.copyWith(message: LocaleKeys.checkDownloadsScreen));
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaySettingsScreenStatus.error,
          failure: Failure.fromException(e),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _playbackSubscription.cancel();
    return super.close();
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

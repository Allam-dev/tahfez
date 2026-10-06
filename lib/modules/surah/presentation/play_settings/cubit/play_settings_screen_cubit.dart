import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
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
      emit(state.copyWith(playbackInfo: playbackInfo));
    });
    if (playParams != null) {
      _initializePlayParams(playParams);
    }
  }

  Future<void> _initializePlayParams(SurahPlayParams playParams) async {
    await _player.stop();
    emit(
      PlaySettingsScreenState(
        playParams: playParams,
        downloadWhilePlaying: false,
      ),
    );
  }

  void changeReader(ReaderModel reader) {
    emit(state.copyWith(playParams: state.playParams.copyWith(reader: reader)));
  }

  void changeStartSurah(int? surahNumber) {
    if (surahNumber == null || !state.playbackInfo.playerState.isIdel) return;

    emit(
      state.copyWith(playParams: state.playParams.setStartSurah(surahNumber)),
    );
  }

  void changeStartAya(int? aya) {
    if (aya == null || !state.playbackInfo.playerState.isIdel) return;
    emit(state.copyWith(playParams: state.playParams.setStartAya(aya)));
  }

  void changeEndSurah(int? surahNumber) {
    if (surahNumber == null || !state.playbackInfo.playerState.isIdel) return;
    emit(state.copyWith(playParams: state.playParams.setEndSurah(surahNumber)));
  }

  void changeEndAya(int? aya) {
    if (aya == null || !state.playbackInfo.playerState.isIdel) return;
    emit(state.copyWith(playParams: state.playParams.setEndAya(aya)));
  }

  void switchPlayAudio(bool? value) {
    if (value != null && state.playbackInfo.playerState.isIdel) {
      emit(
        state.copyWith(
          playAudio: value,
          downloadWhilePlaying: value,
          downloadingOnly: !value,
        ),
      );
    }
  }

  void switchDownloadWhilePlaying(bool? value) {
    if (value != null && state.playbackInfo.playerState.isIdel) {
      emit(
        state.copyWith(
          playAudio: true,
          downloadWhilePlaying: value,
          downloadingOnly: false,
        ),
      );
    }
  }

  void switchDownloadOnly(bool? value) {
    if (value != null && state.playbackInfo.playerState.isIdel) {
      emit(
        state.copyWith(
          playAudio: !value,
          downloadWhilePlaying: !value,
          downloadingOnly: value,
        ),
      );
    }
  }

  void incrementAyaRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;
    emit(state.copyWith(playParams: state.playParams.incrementAyaRepetition()));
  }

  void decrementAyaRepetition() {
    if (!state.playbackInfo.playerState.isIdel ||
        state.playParams.ayaRepeatCount <= 1) {
      return;
    }
    emit(state.copyWith(playParams: state.playParams.decrementAyaRepetition()));
  }

  void incrementSectionRepetition() {
    if (!state.playbackInfo.playerState.isIdel) return;

    emit(
      state.copyWith(playParams: state.playParams.incrementSectionRepetition()),
    );
  }

  void decrementSectionRepetition() {
    if (!state.playbackInfo.playerState.isIdel ||
        state.playParams.sectionRepeatCount <= 1) {
      return;
    }

    emit(
      state.copyWith(playParams: state.playParams.decrementSectionRepetition()),
    );
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

  Future<void> start() async {
    _play();

    _download();
  }

  Future<void> _play() async {
    if (state.playAudio) {
      try {
        await _player.start(state.playParams);
      } catch (e) {
        emit(state.copyWith(failure: Failure.fromException(e)));
      }
    }
  }

  Future<void> _download() async {
    if (state.downloadWhilePlaying || state.downloadingOnly) {
      try {
        if (!state.playAudio) {
          emit(
            state.copyWith(
              message: LocaleKeys.preparingDownloads,
              playbackInfo: state.playbackInfo.withState(
                SurahPlayerState.loading,
              ),
            ),
          );
        }

        await _downloader.downloadRange(
          state.playParams.reader,
          state.playParams.startSurahNumber,
          state.playParams.endSurahNumber,
        );

        if (!state.playAudio) {
          emit(
            state.copyWith(
              message: LocaleKeys.checkDownloadsScreen,
              playbackInfo: state.playbackInfo.withState(SurahPlayerState.idel),
            ),
          );
        }
      } catch (e) {
        emit(state.copyWith(failure: Failure.fromException(e)));
      }
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
    Log.info("storing play settings: ${state.playParams.toJson()}");
    return {
      'play_params': state.playParams.toJson(),
      'play_audio': state.playAudio,
      'download_while_playing': state.downloadWhilePlaying,
      'downloading_only': state.downloadingOnly,
    };
  }
}

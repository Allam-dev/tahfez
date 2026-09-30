import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tahfez/modules/surah/data/data_sources/db/mushaf_db.dart';
import 'package:tahfez/modules/surah/domain/models/line_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'moshaf_screen_state.dart';

class MoshafScreenCubit extends Cubit<MoshafScreenState> {
  final SurahPlayer _player;
  final mushafDB = MushafDb.instance;

  late StreamSubscription<SurahPlaybackInfo> _playbackSubscription;
  MoshafScreenCubit(this._player) : super(const MoshafScreenState()) {
    _playbackSubscription = _player.status.listen((playbackInfo) async {
      if (playbackInfo.ayaMetaData != null &&
          playbackInfo.ayaMetaData?.pageNumber !=
              state.playbackInfo.ayaMetaData?.pageNumber) {
        final lines = await mushafDB.getPage(
          playbackInfo.ayaMetaData!.pageNumber,
        );
        emit(state.copyWith(playbackInfo: playbackInfo, lines: lines));
      } else {
        emit(state.copyWith(playbackInfo: playbackInfo));
      }
    });
  }

  @override
  Future<void> close() {
    _playbackSubscription.cancel();
    return super.close();
  }
}

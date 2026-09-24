import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'moshaf_screen_state.dart';

class MoshafScreenCubit extends Cubit<SurahPlaybackInfo> {
  final SurahPlayer _player;
  late StreamSubscription<SurahPlaybackInfo> _playbackSubscription;
  MoshafScreenCubit(this._player) : super(SurahPlaybackInfo.idle()) {
    _playbackSubscription = _player.status.listen((state) {
      emit(state);
    });
  }

  @override
  Future<void> close() {
    _playbackSubscription.cancel();
    return super.close();
  }
}

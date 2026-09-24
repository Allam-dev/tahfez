import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';

part 'play_screen_state.dart';

class PlayScreenCubit extends Cubit<PlayScreenState> {
  final SurahPlayer _player;
  late StreamSubscription<SurahPlaybackInfo> _playbackSubscription;

  PlayScreenCubit(this._player) : super(PlayScreenSettingsState()) {
    _playbackSubscription = _player.status.listen((state) {
      if (state.playerState == SurahPlayerState.idel) {
        emit(PlayScreenSettingsState());
      } else {
        emit(PlayScreenMoshafState());
      }
    });
  }

  @override
  Future<void> close() {
    _playbackSubscription.cancel();
    return super.close();
  }
}

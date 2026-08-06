import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';

abstract class SurahPlayer {
  Future<void> play(SurahPlayParams params);
  Future<void> pause();
  Future<void> stop();
  Stream<SurahPlayerState> get state;
  Future<void> dispose();
}

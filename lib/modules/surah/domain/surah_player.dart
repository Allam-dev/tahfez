import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';

abstract class SurahPlayer {
  /// waiting for loading media
  Future<void> play(SurahPlayParams params);
  void pause();
  void stop();
  void resume();
  Stream<SurahPlayerState> get state;
  Future<void> dispose();
}

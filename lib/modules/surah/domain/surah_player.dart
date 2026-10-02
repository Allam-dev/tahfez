import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';

abstract class SurahPlayer {
  /// Starts a new playback session from scratch.
  Future<void> start(SurahPlayParams params);
  Future<void> pause();
  Future<void> stop();
  Future<void> resume();

  /// Single unified stream: player state + real-time playback info.
  /// Always has a current value (starts with idle).
  Stream<SurahPlaybackInfo> get status;

  Future<void> dispose();
}

import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';

abstract class SurahRepo {
  Future<void> downloadSurah(int surahId, int readerId);
  Future<void> downloadSur(int readerId);
  Future<void> play(SurahPlayParams params);
}

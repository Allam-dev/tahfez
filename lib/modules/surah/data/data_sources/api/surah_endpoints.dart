abstract interface class SurahEndpoints {
  static String getTiming({required int surahNumber, required int readerId}) =>
      'hafs_timing/${readerId}_$surahNumber.json';
}

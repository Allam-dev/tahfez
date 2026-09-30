enum LineTypeEnum {
  surahName,
  basmallah,
  aya;

  static LineTypeEnum fromString(String s) {
    switch (s.toLowerCase()) {
      case 'surah_name':
        return LineTypeEnum.surahName;
      case 'basmallah':
        return LineTypeEnum.basmallah;
      case 'ayah':
        return LineTypeEnum.aya;
      default:
        throw Exception('invalid line type $s');
    }
  }
}

import 'dart:math';

import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

class SurahPlayParams {
  // start
  int startSurahNumber;
  int startAya;

  // end
  int endSurahNumber;
  int endAya;

  ReaderModel reader;

  // repeat
  int _ayaRepeatCount;
  int _sectionRepeatCount;

  SurahPlayParams({
    required this.startSurahNumber,
    required this.endSurahNumber,
    required this.reader,
    required this.startAya,
    required this.endAya,
    int ayaRepeatCount = 1,
    int sectionRepeatCount = 1,
  }) : _ayaRepeatCount = max(ayaRepeatCount, 1),
       _sectionRepeatCount = max(sectionRepeatCount, 1);

  bool get sameSurah => startSurahNumber == endSurahNumber;

  int get ayaRepeatCount => _ayaRepeatCount;
  int get sectionRepeatCount => _sectionRepeatCount;

  set ayaRepeatCount(int count) {
    _ayaRepeatCount = max(count, 1);
  }

  set sectionRepeatCount(int count) {
    _sectionRepeatCount = max(count, 1);
  }
}

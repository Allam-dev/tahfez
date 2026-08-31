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


  factory SurahPlayParams.fromJson(Map<String, dynamic> json) {
    return SurahPlayParams(
      startSurahNumber: json['startSurahNumber'] as int,
      endSurahNumber: json['endSurahNumber'] as int,
      reader: ReaderModel.fromApiJson(json['reader'] as Map<String, dynamic>),
      startAya: json['startAya'] as int,
      endAya: json['endAya'] as int,
      ayaRepeatCount: json['ayaRepeatCount'] as int,
      sectionRepeatCount: json['sectionRepeatCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'startSurahNumber': startSurahNumber,
    'endSurahNumber': endSurahNumber,
    'reader':reader.toJson(),
    'startAya': startAya,
    'endAya': endAya,
    'ayaRepeatCount': _ayaRepeatCount,
    'sectionRepeatCount': _sectionRepeatCount,
  };
}

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';

class SurahPlayParams extends Equatable {
  // start
  final int startSurahNumber;
  final int startAya;

  // end
  final int endSurahNumber;
  final int endAya;

  final ReaderModel reader;

  // repeat
  final int _ayaRepeatCount;
  final int _sectionRepeatCount;

  const SurahPlayParams({
    required this.startSurahNumber,
    required this.endSurahNumber,
    required this.reader,
    required this.startAya,
    required this.endAya,
    int ayaRepeatCount = 1,
    int sectionRepeatCount = 1,
  }) : _ayaRepeatCount = ayaRepeatCount < 1 ? 1 : ayaRepeatCount,
       _sectionRepeatCount = sectionRepeatCount < 1 ? 1 : sectionRepeatCount;
  bool get sameSurah => startSurahNumber == endSurahNumber;

  int get ayaRepeatCount => _ayaRepeatCount;
  int get sectionRepeatCount => _sectionRepeatCount;

  SurahPlayParams setAyaRepeatCount(int count) {
    return copyWith(ayaRepeatCount: max(1, count));
  }

  SurahPlayParams incrementAyaRepetition() {
    return setAyaRepeatCount(_ayaRepeatCount + 1);
  }

  SurahPlayParams decrementAyaRepetition() {
    return setAyaRepeatCount(_ayaRepeatCount - 1);
  }

  SurahPlayParams setSectionRepeatCount(int count) {
    return copyWith(sectionRepeatCount: max(1, count));
  }

  SurahPlayParams incrementSectionRepetition() {
    return setSectionRepeatCount(_sectionRepeatCount + 1);
  }

  SurahPlayParams decrementSectionRepetition() {
    return setSectionRepeatCount(_sectionRepeatCount - 1);
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
    'reader': reader.toJson(),
    'startAya': startAya,
    'endAya': endAya,
    'ayaRepeatCount': _ayaRepeatCount,
    'sectionRepeatCount': _sectionRepeatCount,
  };

  SurahPlayParams copyWith({
    int? startSurahNumber,
    int? startAya,
    int? endSurahNumber,
    int? endAya,
    ReaderModel? reader,
    int? ayaRepeatCount,
    int? sectionRepeatCount,
  }) {
    return SurahPlayParams(
      startSurahNumber: startSurahNumber ?? this.startSurahNumber,
      startAya: startAya ?? this.startAya,
      endSurahNumber: endSurahNumber ?? this.endSurahNumber,
      endAya: endAya ?? this.endAya,
      reader: reader ?? this.reader,
      ayaRepeatCount: ayaRepeatCount ?? _ayaRepeatCount,
      sectionRepeatCount: sectionRepeatCount ?? _sectionRepeatCount,
    );
  }

  SurahPlayParams setStartSurah(int surahNumber) {
    surahNumber = surahNumber.clamp(1, SUR.length);
    return copyWith(
      startSurahNumber: surahNumber,
      startAya: 1,
      endSurahNumber: surahNumber,
      endAya: SUR[surahNumber - 1].versesCount,
    );
  }

  SurahPlayParams setStartAya(int aya) {
    aya = aya.clamp(1, SUR[startSurahNumber - 1].versesCount);
    int endSurahNumber = startSurahNumber;
    int endAya = SUR[startSurahNumber - 1].versesCount;
    if (aya == SUR[startSurahNumber - 1].versesCount) {
      endSurahNumber++;
      endAya = SUR[startSurahNumber].versesCount;
    }
    return copyWith(
      startAya: aya,
      endSurahNumber: endSurahNumber,
      endAya: endAya,
    );
  }

  SurahPlayParams setEndSurah(int surahNumber) {
    surahNumber = surahNumber.clamp(startSurahNumber, SUR.length);
    return copyWith(
      endSurahNumber: surahNumber,
      endAya: SUR[surahNumber - 1].versesCount,
    );
  }

  SurahPlayParams setEndAya(int aya) {
    int lowerLimit;
    if (sameSurah) {
      lowerLimit = startAya;
    } else {
      lowerLimit = 1;
    }
    return copyWith(
      endAya: aya.clamp(lowerLimit, SUR[endSurahNumber - 1].versesCount),
    );
  }

  @override
  String toString() {
    return 'SurahPlayParams(startSurahNumber: $startSurahNumber, endSurahNumber: $endSurahNumber, startAya: $startAya, endAya: $endAya, reader: ${reader.id}, ayaRepeatCount: $ayaRepeatCount, sectionRepeatCount: $sectionRepeatCount)';
  }

  @override
  List<Object?> get props => [
    startSurahNumber,
    endSurahNumber,
    reader,
    startAya,
    endAya,
    _ayaRepeatCount,
    _sectionRepeatCount,
  ];
}

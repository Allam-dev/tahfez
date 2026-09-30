import 'package:tahfez/modules/surah/domain/enums/line_type_enum.dart';
import 'package:tahfez/modules/surah/domain/models/word_model.dart';

class LineModel {
  final int id;
  final LineTypeEnum type;
  final bool isCentered;
  List<WordModel>? words;
  int? firstWord;
  int? lastWord;

  LineModel({
    required this.id,
    required this.type,
    required this.isCentered,
    this.words,
    this.firstWord,
    this.lastWord,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      id: json['line_number'],
      type: LineTypeEnum.fromString(json['line_type']),
      isCentered: json['line_number'] == 1,
      firstWord: int.tryParse(json['first_word_id'].toString()),
      lastWord: int.tryParse(json['last_word_id'].toString()),
    );
  }
}

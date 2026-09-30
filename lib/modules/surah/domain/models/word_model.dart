
class WordModel {
  final int id;
  final String text;
  final int aya;
  final int surah;

  WordModel({
    required this.aya,
    required this.text,
    required this.id,
    required this.surah,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'],
      text: json['text'],
      aya: json['ayah'],
      surah: json['surah'],
    );
  }
}

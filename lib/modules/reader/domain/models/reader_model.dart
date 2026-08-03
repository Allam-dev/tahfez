class ReaderModel {
  final int id;
  final String name;
  final String rewaya;
  final String downloadUrl;
  ReaderModel({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.downloadUrl,
  });

  factory ReaderModel.fromApiJson(Map<String, dynamic> json) {
    return ReaderModel(
      id: json['id'],
      name: json['name'],
      rewaya: json['rewaya'],
      downloadUrl: json['folder_url'],
    );
  }

  factory ReaderModel.fake() => ReaderModel(
    id: 0,
    name: 'name',
    rewaya: 'rewaya',
    downloadUrl: 'downloadUrl',
  );

  String get nameWithRewaya => '$name ($rewaya)';
}

import 'package:equatable/equatable.dart';

class ReaderModel extends Equatable {
  final int id;
  final String name;
  final String rewaya;
  final String downloadUrl;
  const ReaderModel({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.downloadUrl,
  });

  factory ReaderModel.fromApiJson(Map<String, dynamic> json) {
    String name = json['name'].toString();
    final String rewaya = json['rewaya'].toString();

    if (rewaya.contains('مجود')) {
      name = "$name ($rewaya)";
    }

    if ((json['rewaya'].toString().contains('مجود'))) {}
    return ReaderModel(
      id: json['id'],
      name: name,
      rewaya: rewaya,
      downloadUrl: json['folder_url'],
    );
  }

  factory ReaderModel.fake() => const ReaderModel(
    id: 0,
    name: 'name',
    rewaya: 'rewaya',
    downloadUrl: 'downloadUrl',
  );

  String get nameWithRewaya => '$name ($rewaya)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rewaya': rewaya,
    'folder_url': downloadUrl,
  };

  @override
  List<Object?> get props => [id];
}

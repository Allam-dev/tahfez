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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rewaya': rewaya,
    'folder_url': downloadUrl,
  };

  @override
  List<Object?> get props => [id];
}

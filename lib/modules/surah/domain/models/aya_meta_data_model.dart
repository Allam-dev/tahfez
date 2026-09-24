import 'package:equatable/equatable.dart';

class AyaMetaDataModel extends Equatable {
  final int id;

  /// time in millisecond
  final int startTime;

  /// time in millisecond
  final int endTime;

  final String polygon;
  final String pageFileName;

  const AyaMetaDataModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.polygon,
    required this.pageFileName,
  });

  factory AyaMetaDataModel.fromApiJson(Map<String, dynamic> json) {
    return AyaMetaDataModel(
      id: json['ayah'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      polygon: json['polygon'],
      pageFileName: json['page'].toString().split('/').last,
    );
  }

  @override
  List<Object?> get props => [id, pageFileName];
}

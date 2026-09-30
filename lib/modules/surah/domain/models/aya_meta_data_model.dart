import 'package:equatable/equatable.dart';

class AyaMetaDataModel extends Equatable {
  final int id;

  /// time in millisecond
  final int startTime;

  /// time in millisecond
  final int endTime;

  final String polygon;
  final String pageFileName;
  final int pageNumber;

  const AyaMetaDataModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.polygon,
    required this.pageFileName,
    required this.pageNumber,
  });

  factory AyaMetaDataModel.fromApiJson(Map<String, dynamic> json) {
    return AyaMetaDataModel(
      id: json['ayah'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      polygon: json['polygon'],
      pageFileName: json['page'].toString().split('/').last,
      pageNumber: int.parse(json['page'].toString().split('/').last.split(".").first),
    );
  }

  @override
  List<Object?> get props => [id, pageFileName, pageNumber];
}

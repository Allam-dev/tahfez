class AyaMetaDataModel {
  final int id;

  /// time in millisecond
  final int startTime;

  /// time in millisecond
  final int endTime;

  final String polygon;
  final String pageFileName;

  AyaMetaDataModel({
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
      pageFileName: json['page'],
    );
  }
}

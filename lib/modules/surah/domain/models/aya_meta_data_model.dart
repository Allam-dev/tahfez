class AyaMetaDataModel {
  final int id;

  /// time in millisecond
  final int startTime;

  /// time in millisecond
  final int endTime;

  AyaMetaDataModel({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  factory AyaMetaDataModel.fromApiJson(Map<String, dynamic> json) {
    return AyaMetaDataModel(
      id: json['ayah'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

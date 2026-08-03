class AyaTimingModel {
  final int id;

  /// time in millisecond
  final int startTime;

  /// time in millisecond
  final int endTime;

  AyaTimingModel({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  factory AyaTimingModel.fromApiJson(Map<String, dynamic> json) {
    return AyaTimingModel(
      id: json['ayah'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

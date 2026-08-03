import 'dart:math';

class XyzModel {
  final String id;

  XyzModel({required this.id});

  factory XyzModel.fromApiJson(Map<String, dynamic> json) {
    return XyzModel(id: json['id'].toString());
  }

  factory XyzModel.fromDbJson(Map<String, dynamic> json) {
    return XyzModel(id: json['id'].toString());
  }

  factory XyzModel.fake() {
    return XyzModel(id: Random().nextInt(1000).toString());
  }

  Map<String, dynamic> toApiJson() {
    return {};
  }


    Map<String, dynamic> toDbJson() {
    return {};
  }
}

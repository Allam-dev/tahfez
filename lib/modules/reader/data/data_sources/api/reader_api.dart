import 'package:dio/dio.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/data/data_sources/api/reader_endpoints.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

List<ReaderModel> _readers = [];

class ReaderAPI {
  final Dio _dio = DioFactory.instance.dio;

  Future<List<ReaderModel>> getList() async {
    if (_readers.isNotEmpty) return _readers;
    final response = await _dio.get(ReaderEndpoints.getList);

    for (final json in response.data as List) {
      final reader = ReaderModel.fromApiJson(json);
      _readers.add(reader);
    }
    Log.info(_readers.length.toString());
    return _readers;
  }
}

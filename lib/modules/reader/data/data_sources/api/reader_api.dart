import 'package:dio/dio.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/data/data_sources/api/reader_endpoints.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

class ReaderAPI {
  final Dio _dio = DioFactory.instance.dio;

  final _badReaders = [
    14,
    16,
    31,
    51,
    62,
    65,
    67,
    74,
    75,
    80,
    87,
    112,
    118,
    120,
    134,
    208,
    269,
    270,
  ];

  Future<List<ReaderModel>> getList() async {
    final response = await _dio.get(
      ReaderEndpoints.getList,
      options: Options(extra: {'reload': true}),
    );
    List<ReaderModel> readers = [];
    for (final json in response.data as List) {
      final reader = ReaderModel.fromApiJson(json);
      if (json['soar_count'] == 114 &&
          reader.rewaya.contains('حفص') &&
          !_badReaders.contains(reader.id)) {
        readers.add(reader);
      }
    }
    Log.info(readers.length.toString());
    return readers;
  }
}

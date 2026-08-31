import 'package:dio/dio.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/modules/reader/data/data_sources/api/reader_endpoints.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

class ReaderAPI {
  final Dio _dio = DioFactory.instance.dio;

  Future<Map<String,List<ReaderModel>>> getList() async {
    final response = await _dio.get(
      ReaderEndpoints.getList,
      options: Options(extra: {'reload': true}),
    );
    Map<String,List<ReaderModel>> readers = {};
    for (final json in response.data as List) {
      if (json['soar_count'] == 114) {
        final reader = ReaderModel.fromApiJson(json);
        if(readers.containsKey(reader.rewaya)){
          readers[reader.rewaya]!.add(reader);
        }else{
          readers[reader.rewaya] = [reader];
        }
      }
    }
    return readers;
  }
}

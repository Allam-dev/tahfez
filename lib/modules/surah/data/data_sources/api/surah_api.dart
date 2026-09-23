import 'package:dio/dio.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_endpoints.dart';
import 'package:tahfez/modules/surah/domain/models/aya_meta_data_model.dart';

class SurahAPI {
  final Dio _dio = DioFactory.instance.dio;

  Future<List<AyaMetaDataModel>> getTiming(int surahId, int readerId) async {
    final response = await _dio.get(
      SurahEndpoints.getTiming,
      queryParameters: {'surah': surahId, 'read': readerId},
    );
    final List<AyaMetaDataModel> timings = [];
    for (final aya in response.data as List) {
      if (aya['ayah'] == 0) continue;
      timings.add(AyaMetaDataModel.fromApiJson(aya));
    }
    return timings;
  }
}

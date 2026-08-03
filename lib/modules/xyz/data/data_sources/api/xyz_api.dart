import 'package:dio/dio.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/modules/xyz/data/data_sources/api/xyz_endpoints.dart';
import 'package:tahfez/modules/xyz/domain/models/xyz_model.dart';
import 'package:tahfez/modules/xyz/domain/params/create_xyz_params.dart';
import 'package:tahfez/modules/xyz/domain/params/get_xyz_list_filter.dart';

class XyzAPI {
  final Dio _dio = DioFactory.instance.dio;

  Future<List<XyzModel>> getList(GetXyzListFilter filter) async {
    final response = await _dio.get(
      XyzEndpoints.getList,
      queryParameters: filter.toApiJson(),
    );
    return (response.data as List).map((e) => XyzModel.fromApiJson(e)).toList();
  }

  Future<XyzModel> getOne(String id) async {
    final response = await _dio.get(XyzEndpoints.getOne(id));
    return XyzModel.fromApiJson(response.data);
  }

  Future<XyzModel> create(CreateXyzParams params) async {
    final response = await _dio.post(
      XyzEndpoints.create,
      data: params.toApiJson(),
    );
    return XyzModel.fromApiJson(response.data);
  }

  Future<XyzModel> update(XyzModel model) async {
    final response = await _dio.put(
      XyzEndpoints.update(model.id),
      data: model.toApiJson(),
    );
    return XyzModel.fromApiJson(response.data);
  }

  Future<void> delete(String id) async {
    await _dio.delete(XyzEndpoints.delete(id));
  }
}

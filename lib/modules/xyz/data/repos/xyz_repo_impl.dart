import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/xyz/data/data_sources/api/xyz_api.dart';
import 'package:tahfez/modules/xyz/domain/models/xyz_model.dart';
import 'package:tahfez/modules/xyz/domain/params/create_xyz_params.dart';
import 'package:tahfez/modules/xyz/domain/params/get_xyz_list_filter.dart';
import '../../domain/xyz_repo.dart';

class XyzRepoImpl implements XyzRepo {
  final XyzAPI _api = XyzAPI();
  @override
  Future<Either<Failure, List<XyzModel>>> getList(
    GetXyzListFilter filter,
  ) async {
    try {
      final result = await _api.getList(filter);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, XyzModel>> getOne(String id) async {
    try {
      final result = await _api.getOne(id);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, XyzModel>> create(CreateXyzParams params) async {
    try {
      final result = await _api.create(params);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, XyzModel>> update(XyzModel model) async {
    try {
      final result = await _api.update(model);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _api.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

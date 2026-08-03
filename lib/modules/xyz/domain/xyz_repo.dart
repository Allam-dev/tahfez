import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/xyz/domain/models/xyz_model.dart';
import 'package:tahfez/modules/xyz/domain/params/create_xyz_params.dart';
import 'package:tahfez/modules/xyz/domain/params/get_xyz_list_filter.dart';

abstract class XyzRepo {
  Future<Either<Failure, List<XyzModel>>> getList(GetXyzListFilter filter);

  Future<Either<Failure, XyzModel>> getOne(String id);

  Future<Either<Failure, XyzModel>> create(CreateXyzParams params);

  Future<Either<Failure, XyzModel>> update(XyzModel model);

  Future<Either<Failure, Unit>> delete(String id);
}

import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/xyz/domain/models/xyz_model.dart';
import 'package:tahfez/modules/xyz/domain/params/create_xyz_params.dart';
import 'package:tahfez/modules/xyz/domain/params/get_xyz_list_filter.dart';

import '../../domain/xyz_repo.dart';

class XyzRepoFakeImpl implements XyzRepo {
  @override
  Future<Either<Failure, List<XyzModel>>> getList(
    GetXyzListFilter filter,
  ) async {
    await _delay();

    if (Random().nextBool()) {
      return Right(
        List.generate(Random().nextInt(30), (index) => XyzModel.fake()),
      );
    }
    return Left(Failure(message: 'Failed to fetch Xyz list'));
  }

  @override
  Future<Either<Failure, XyzModel>> getOne(String id) async {
    await _delay();

    if (Random().nextBool()) {
      return Right(XyzModel.fake());
    }
    return Left(Failure(message: 'Failed to fetch Xyz list'));
  }

  @override
  Future<Either<Failure, XyzModel>> create(CreateXyzParams params) async {
    await _delay();

    if (Random().nextBool()) {
      return Right(XyzModel.fake());
    }
    return Left(Failure(message: 'Failed to create Xyz'));
  }

  @override
  Future<Either<Failure, XyzModel>> update(XyzModel model) async {
    await _delay();

    if (Random().nextBool()) {
      return Right(model);
    }
    return Left(Failure(message: 'Failed to update Xyz'));
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    await _delay();
    if (Random().nextBool()) {
      return const Right(unit);
    }
    return Left(Failure(message: 'Failed to delete Xyz'));
  }

  Future<void> _delay() => Future.delayed(const Duration(seconds: 2));
}

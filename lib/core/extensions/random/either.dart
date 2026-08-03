import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';

extension RondomizeEither on Random {
  Either<Failure, T> either<T>({required T right}) {
    if (Random().nextBool()) {
      return Right(right);
    } else {
      return Left(Failure());
    }
  }

  Future<Either<Failure, T>> futureEither<T>({required T right}) async {
    await Future.delayed(Duration(seconds: 3));
    return either<T>(right: right);
  }
}

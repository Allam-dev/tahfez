import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

abstract class ReaderRepo {
  Future<Either<Failure, List<ReaderModel>>> getList();
}

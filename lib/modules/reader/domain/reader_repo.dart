import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

abstract class ReaderRepo {
  /// get all readers grouped by riwaya
  Future<Either<Failure, Map<String, List<ReaderModel>>>> getList();
}

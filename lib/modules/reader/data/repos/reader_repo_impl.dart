import 'package:fpdart/fpdart.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/data/data_sources/api/reader_api.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import '../../domain/reader_repo.dart';

class ReaderRepoImpl implements ReaderRepo {
  final ReaderAPI _api = ReaderAPI();
  @override
  Future<Either<Failure, Map<String,List<ReaderModel>>>> getList() async {
    try {
      final result = await _api.getList();
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

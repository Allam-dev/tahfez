/// import 'dart:math';
/// import 'package:fpdart/fpdart.dart';
/// import 'package:tahfez/core/error/failure.dart';
/// import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
/// import 'package:tahfez/modules/reader/domain/params/create_reader_params.dart';
/// import 'package:tahfez/modules/reader/domain/params/get_reader_list_filter.dart';

/// import '../../domain/reader_repo.dart';

/// class ReaderRepoFakeImpl implements ReaderRepo {
///   @override
///   Future<Either<Failure, List<ReaderModel>>> getList(
///     GetReaderListFilter filter,
///   ) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(
///         List.generate(Random().nextInt(30), (index) => ReaderModel.fake()),
///       );
///     }
///     return Left(Failure(message: 'Failed to fetch Reader list'));
///   }

///   @override
///   Future<Either<Failure, ReaderModel>> getOne(String id) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(ReaderModel.fake());
///     }
///     return Left(Failure(message: 'Failed to fetch Reader list'));
///   }

///   @override
///   Future<Either<Failure, ReaderModel>> create(CreateReaderParams params) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(ReaderModel.fake());
///     }
///     return Left(Failure(message: 'Failed to create Reader'));
///   }

///   @override
///   Future<Either<Failure, ReaderModel>> update(ReaderModel model) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(model);
///     }
///     return Left(Failure(message: 'Failed to update Reader'));
///   }

///   @override
///   Future<Either<Failure, Unit>> delete(String id) async {
///     await _delay();
///     if (Random().nextBool()) {
///       return const Right(unit);
///     }
///     return Left(Failure(message: 'Failed to delete Reader'));
///   }

///   Future<void> _delay() => Future.delayed(const Duration(seconds: 2));
/// }

/// import 'dart:math';
/// import 'package:fpdart/fpdart.dart';
/// import 'package:tahfez/core/error/failure.dart';
/// import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
/// import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
/// import 'package:tahfez/modules/surah/domain/params/get_surah_list_filter.dart';

/// import '../../domain/surah_repo.dart';

/// class SurahRepoFakeImpl implements SurahRepo {
///   @override
///   Future<Either<Failure, List<SurahModel>>> getList(
///     GetSurahListFilter filter,
///   ) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(
///         List.generate(Random().nextInt(30), (index) => SurahModel.fake()),
///       );
///     }
///     return Left(Failure(message: 'Failed to fetch Surah list'));
///   }

///   @override
///   Future<Either<Failure, SurahModel>> getOne(String id) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(SurahModel.fake());
///     }
///     return Left(Failure(message: 'Failed to fetch Surah list'));
///   }

///   @override
///   Future<Either<Failure, SurahModel>> create(CreateSurahParams params) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(SurahModel.fake());
///     }
///     return Left(Failure(message: 'Failed to create Surah'));
///   }

///   @override
///   Future<Either<Failure, SurahModel>> update(SurahModel model) async {
///     await _delay();

///     if (Random().nextBool()) {
///       return Right(model);
///     }
///     return Left(Failure(message: 'Failed to update Surah'));
///   }

///   @override
///   Future<Either<Failure, Unit>> delete(String id) async {
///     await _delay();
///     if (Random().nextBool()) {
///       return const Right(unit);
///     }
///     return Left(Failure(message: 'Failed to delete Surah'));
///   }

///   Future<void> _delay() => Future.delayed(const Duration(seconds: 2));
/// }

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

part 'readers_dropdown_state.dart';

class ReadersDropdownCubit extends Cubit<ReadersDropdownState> {
  final ReaderRepo _readerRepo;
  ReadersDropdownCubit(this._readerRepo) : super(ReadersDropdownInitialState());

  Future<void> getList() async {
    emit(ReadersDropdownLoadingState());
    final result = await _readerRepo.getList();
    result.fold(
      (failure) => emit(ReadersDropdownFailureState(failure)),
      (readers) => emit(ReadersDropdownLoadedState(readers)),
    );
  }
}

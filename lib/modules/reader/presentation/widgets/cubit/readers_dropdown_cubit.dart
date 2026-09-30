import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

part 'readers_dropdown_state.dart';

class ReadersDropdownCubit extends HydratedCubit<ReadersDropdownState> {
  final ReaderRepo _readerRepo;
  ReadersDropdownCubit(this._readerRepo) : super(ReadersDropdownState());

  Future<void> getList() async {
    emit(state.copyWith(status: ReadersDropdownStatus.loading));
    final result = await _readerRepo.getList();
    result.fold(
      (failure) => emit(
        state.copyWith(failure: failure, status: ReadersDropdownStatus.error),
      ),
      (readers) {
        bool isReaderExist = readers.contains(state.selectedReader);
        if (isReaderExist) {
          emit(
            state.copyWith(
              readers: readers,
              status: ReadersDropdownStatus.loaded,
            ),
          );
        } else {
          emit(
            state.copyWith(
              selectedReader: readers.first,
              readers: readers,
              status: ReadersDropdownStatus.loaded,
            ),
          );
        }
      },
    );
  }

  void changeReader(ReaderModel? reader) {
    if (reader != null) {
      emit(
        state.copyWith(
          status: ReadersDropdownStatus.readerChanged,
          selectedReader: reader,
        ),
      );
    }
  }

  @override
  ReadersDropdownState? fromJson(Map<String, dynamic> json) {
    return ReadersDropdownState(selectedReader: ReaderModel.fromApiJson(json));
  }

  @override
  Map<String, dynamic>? toJson(ReadersDropdownState state) {
    return state.selectedReader?.toJson();
  }
}

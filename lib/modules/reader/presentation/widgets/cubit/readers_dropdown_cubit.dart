import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

part 'readers_dropdown_state.dart';

class ReadersDropdownCubit extends HydratedCubit<ReadersDropdownState> {
  final ReaderRepo _readerRepo;
  final ReaderModel? _initialReader;
  ReadersDropdownCubit(this._readerRepo, this._initialReader)
    : super(ReadersDropdownState());

  Future<void> getList() async {
    emit(state.copyWith(status: ReadersDropdownStatus.loading));
    final result = await _readerRepo.getList();
    result.fold(
      (failure) => emit(
        state.copyWith(failure: failure, status: ReadersDropdownStatus.error),
      ),
      (readers) {
        bool isReaderExist = readers.contains(
          (_initialReader ?? state.selectedReader),
        );
        if (isReaderExist) {
          emit(
            state.copyWith(
              readers: readers,
              selectedReader: _initialReader,
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
    Log.warning(
      state.selectedReader?.toJson().toString() ?? 'no initial reader',
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
    Log.info("storing reader: ${state.selectedReader?.toJson()}");
    return state.selectedReader?.toJson();
  }
}

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/core/extensions/string/validations.dart';
import 'package:tahfez/core/services/logs/log.dart';
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
      (readersMap) {
        bool isReaderExist =
            readersMap[state.selectedReader?.rewaya]?.contains(
              state.selectedReader,
            ) ??
            false;
        if (isReaderExist) {
          Log.debug(state.selectedReader!.toJson().toString());
          emit(
            state.copyWith(
              readersMap: readersMap,
              status: ReadersDropdownStatus.loaded,
              rewayat: readersMap.keys.toList(),
              selectedRewaya: state.selectedReader?.rewaya,
            ),
          );
        } else {
          emit(
            state.copyWith(
              selectedReader: readersMap.values.first.first,
              readersMap: readersMap,
              status: ReadersDropdownStatus.loaded,
              rewayat: readersMap.keys.toList(),
              selectedRewaya: readersMap.keys.first,
            ),
          );
        }
      },
    );
  }

  void changeRewaya(String? rewaya) {
    if (rewaya.hasValue) {
      emit(
        state.copyWith(
          status: ReadersDropdownStatus.rewayaChanged,
          selectedRewaya: rewaya,
          selectedReader: state.readersMap[rewaya]?.first,
        ),
      );
    }
  }

  void changeReader(ReaderModel? reader) {
    if (reader != null) {
      emit(
        state.copyWith(
          status: ReadersDropdownStatus.readerChanged,
          selectedReader: reader,
          selectedRewaya: reader.rewaya,
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

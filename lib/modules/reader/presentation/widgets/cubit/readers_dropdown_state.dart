part of 'readers_dropdown_cubit.dart';

enum ReadersDropdownStatus {
  initial,
  loading,
  loaded,
  error,
  readerChanged,
}

@immutable
class ReadersDropdownState {
  final ReadersDropdownStatus status;

  final List<ReaderModel> readers;
  final Failure? failure;

  final ReaderModel? selectedReader;

  const ReadersDropdownState({
    this.status = ReadersDropdownStatus.initial,
    this.readers = const [],
    this.failure,
    this.selectedReader,
  });

  ReadersDropdownState copyWith({
    ReadersDropdownStatus? status,
    List<ReaderModel>? readers,
    Failure? failure,
    ReaderModel? selectedReader,
  }) {
    return ReadersDropdownState(
      status: status ?? this.status,
      readers: readers ?? this.readers,
      failure: failure ?? this.failure,
      selectedReader: selectedReader ?? this.selectedReader,
    );
  }
}

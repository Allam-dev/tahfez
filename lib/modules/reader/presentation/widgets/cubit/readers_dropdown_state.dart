part of 'readers_dropdown_cubit.dart';

enum ReadersDropdownStatus {
  initial,
  loading,
  loaded,
  error,
  rewayaChanged,
  readerChanged,
}

@immutable
class ReadersDropdownState {
  final ReadersDropdownStatus status;

  final List<String> rewayat;
  final Map<String, List<ReaderModel>> readersMap;
  final Failure? failure;

  final ReaderModel? selectedReader;
  final String? selectedRewaya;

  const ReadersDropdownState({
    this.status = ReadersDropdownStatus.initial,
    this.rewayat = const [],
    this.readersMap = const {},
    this.failure,
    this.selectedReader,
    this.selectedRewaya,
  });

  ReadersDropdownState copyWith({
    ReadersDropdownStatus? status,
    List<String>? rewayat,
    Map<String, List<ReaderModel>>? readersMap,
    Failure? failure,
    ReaderModel? selectedReader,
    String? selectedRewaya,
  }) {
    return ReadersDropdownState(
      status: status ?? this.status,
      rewayat: rewayat ?? this.rewayat,
      readersMap: readersMap ?? this.readersMap,
      failure: failure ?? this.failure,
      selectedReader: selectedReader ?? this.selectedReader,
      selectedRewaya: selectedRewaya ?? this.selectedRewaya,
    );
  }

  List<ReaderModel> get readersList => readersMap[selectedRewaya] ?? [];
}

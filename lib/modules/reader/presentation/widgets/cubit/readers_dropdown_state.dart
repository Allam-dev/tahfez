part of 'readers_dropdown_cubit.dart';

@immutable
sealed class ReadersDropdownState {}

final class ReadersDropdownInitialState extends ReadersDropdownState {}

final class ReadersDropdownLoadingState extends ReadersDropdownState {}

final class ReadersDropdownLoadedState extends ReadersDropdownState {
  final List<String> rewayat;

  ReadersDropdownLoadedState(this.rewayat);
}

final class ReadersDropdownRewayaChangedState extends ReadersDropdownState {
  final List<ReaderModel> readers;

  ReadersDropdownRewayaChangedState(this.readers);
}

final class ReadersDropdownFailureState extends ReadersDropdownState {
  final Failure failure;

  ReadersDropdownFailureState(this.failure);
}

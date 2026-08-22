part of 'readers_dropdown_cubit.dart';

@immutable
sealed class ReadersDropdownState {}

final class ReadersDropdownInitialState extends ReadersDropdownState {}

final class ReadersDropdownLoadingState extends ReadersDropdownState {}

final class ReadersDropdownLoadedState extends ReadersDropdownState {
  final List<ReaderModel> readers;

  ReadersDropdownLoadedState(this.readers);
}

final class ReadersDropdownFailureState extends ReadersDropdownState {
  final Failure failure;

  ReadersDropdownFailureState(this.failure);
}

part of 'play_screen_cubit.dart';

@immutable
sealed class PlayScreenState {}

final class PlayScreenInitialState extends PlayScreenState {}

final class PlayScreenPlayingState extends PlayScreenState {}

final class PlayScreenPauseState extends PlayScreenState {}

final class PlayScreenLoadingState extends PlayScreenState {}

final class PlayScreenUpdatePlayingParamState extends PlayScreenState {}

final class PlayScreenFailureState extends PlayScreenState {
  final Failure failure;
  PlayScreenFailureState(this.failure);
}

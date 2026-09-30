part of 'moshaf_screen_cubit.dart';

@immutable
class MoshafScreenState extends Equatable {
  final SurahPlaybackInfo playbackInfo;
  final List<LineModel> lines;

  const MoshafScreenState({
    this.playbackInfo = const SurahPlaybackInfo.loading(),
    this.lines = const [],
  });

  MoshafScreenState copyWith({
    SurahPlaybackInfo? playbackInfo,
    List<LineModel>? lines,
  }) {
    return MoshafScreenState(
      playbackInfo: playbackInfo ?? this.playbackInfo,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [playbackInfo];
}

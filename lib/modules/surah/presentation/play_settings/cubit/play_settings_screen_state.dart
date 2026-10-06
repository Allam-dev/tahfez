part of 'play_settings_screen_cubit.dart';

@immutable
class PlaySettingsScreenState {
  final Failure? failure;
  final SurahPlayParams playParams;
  final bool playAudio;
  final bool downloadWhilePlaying;
  final bool downloadingOnly;
  final SurahPlaybackInfo playbackInfo;
  final String? message;
  const PlaySettingsScreenState({
    this.playbackInfo = const SurahPlaybackInfo.idle(),
    this.failure,
    required this.playParams,
    this.playAudio = true,
    this.downloadWhilePlaying = true,
    this.downloadingOnly = false,
    this.message,
  });

  PlaySettingsScreenState copyWith({
    SurahPlaybackInfo? playbackInfo,
    Failure? failure,
    SurahPlayParams? playParams,
    bool? playAudio,
    bool? downloadWhilePlaying,
    bool? downloadingOnly,
    String? message,
  }) {
    return PlaySettingsScreenState(
      failure: failure,
      playParams: playParams ?? this.playParams,
      playAudio: playAudio ?? this.playAudio,
      downloadWhilePlaying: downloadWhilePlaying ?? this.downloadWhilePlaying,
      downloadingOnly: downloadingOnly ?? this.downloadingOnly,
      playbackInfo: playbackInfo ?? this.playbackInfo,
      message: message,
    );
  }

  @override
  String toString() {
    return 'PlaySettingsScreenState(failure: $failure, playParams: ${playParams.toString()}, playAudio: $playAudio, downloadWhilePlaying: $downloadWhilePlaying, downloadingOnly: $downloadingOnly, playbackInfo: $playbackInfo, message: $message)';
  }
}

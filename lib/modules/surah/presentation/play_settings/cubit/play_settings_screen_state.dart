part of 'play_settings_screen_cubit.dart';

enum PlaySettingsScreenStatus {
  inital,
  loading,
  error,
  // range
  startSurahChanged,
  endSurahChanged,
  startAyaChanged,
  endAyaChanged,
  // repeatation
  ayaRepetitionChanged,
  sectionRepetitionChanged,
  // switchs
  switchChanged,


}

@immutable
class PlaySettingsScreenState {
  final PlaySettingsScreenStatus status;
  final Failure? failure;
  final SurahPlayParams playParams;
  final bool playAudio;
  final bool downloadWhilePlaying;
  final bool downloadingOnly;
  final SurahPlaybackInfo playbackInfo;
  final String? message;
  const PlaySettingsScreenState({
    this.status = PlaySettingsScreenStatus.inital,
    this.playbackInfo = const SurahPlaybackInfo.idle(),
    this.failure,
    required this.playParams,
    this.playAudio = true,
    this.downloadWhilePlaying = true,
    this.downloadingOnly = false,
    this.message,
  });

  PlaySettingsScreenState copyWith({
    PlaySettingsScreenStatus? status,
    SurahPlaybackInfo? playbackInfo,
    Failure? failure,
    SurahPlayParams? playParams,
    bool? playAudio,
    bool? downloadWhilePlaying,
    bool? downloadingOnly,
    bool? playerStateChanged,
    String? message,
  }) {
    return PlaySettingsScreenState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      playParams: playParams ?? this.playParams,
      playAudio: playAudio ?? this.playAudio,
      downloadWhilePlaying: downloadWhilePlaying ?? this.downloadWhilePlaying,
      downloadingOnly: downloadingOnly ?? this.downloadingOnly,
      playbackInfo: playbackInfo ?? this.playbackInfo,
      message: message,
    );
  }

}

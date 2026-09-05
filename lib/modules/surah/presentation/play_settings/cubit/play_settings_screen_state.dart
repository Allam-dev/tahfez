part of 'play_settings_screen_cubit.dart';

enum PlaySettingsScreenStatus {
  inital,
  loading,
  error,
  readerChanged,
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

  const PlaySettingsScreenState({
    this.status = PlaySettingsScreenStatus.inital,
    this.failure,
    required this.playParams,
    this.playAudio = true,
    this.downloadWhilePlaying = true,
    this.downloadingOnly = false,
  });

  PlaySettingsScreenState copyWith({
    PlaySettingsScreenStatus? status,
    Failure? failure,
    SurahPlayParams? playParams,
    bool? playAudio,
    bool? downloadWhilePlaying,
    bool? downloadingOnly,
  }) {
    return PlaySettingsScreenState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      playParams: playParams ?? this.playParams,
      playAudio: playAudio ?? this.playAudio,
      downloadWhilePlaying: downloadWhilePlaying ?? this.downloadWhilePlaying,
      downloadingOnly: downloadingOnly ?? this.downloadingOnly,
    );
  }
}

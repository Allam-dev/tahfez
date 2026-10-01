import 'package:equatable/equatable.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_player_state.dart';
import 'package:tahfez/modules/surah/domain/models/aya_meta_data_model.dart';

/// Unified snapshot emitted by [SurahPlayer.status].
///
/// Carries the player state and, when active, all real-time playback
/// metadata the UI needs.
///
/// Use [surahNumber] with the global `SUR` list to resolve surah name,
/// verse count, etc. Use [ayaMetaData] for aya number, polygon, page.
class SurahPlaybackInfo extends Equatable {
  final SurahPlayerState playerState;
  final int surahNumber;
  final AyaMetaDataModel? ayaMetaData;
  final int currentAyaRepeat;
  final int currentSectionRepeat;

  const SurahPlaybackInfo({
    required this.playerState,
    required this.surahNumber,
    required this.ayaMetaData,
    required this.currentAyaRepeat,
    required this.currentSectionRepeat,
  });

  /// Idle state — no playback data.
  const SurahPlaybackInfo.idle()
    : playerState = SurahPlayerState.idel,
      surahNumber = 0,
      ayaMetaData = null,
      currentAyaRepeat = 0,
      currentSectionRepeat = 0;

  const SurahPlaybackInfo.loading()
    : playerState = SurahPlayerState.loading,
      surahNumber = 0,
      ayaMetaData = null,
      currentAyaRepeat = 0,
      currentSectionRepeat = 0;

  bool get isActive =>
      playerState == SurahPlayerState.play ||
      playerState == SurahPlayerState.pause;

  /// Returns a copy with a different [playerState] but same playback data.
  SurahPlaybackInfo withState(SurahPlayerState state) => SurahPlaybackInfo(
    playerState: state,
    surahNumber: surahNumber,
    ayaMetaData: ayaMetaData,
    currentAyaRepeat: currentAyaRepeat,
    currentSectionRepeat: currentSectionRepeat,
  );

  @override
  List<Object?> get props => [
    playerState,
    surahNumber,
    ayaMetaData,
    currentAyaRepeat,
    currentSectionRepeat,
  ];
}

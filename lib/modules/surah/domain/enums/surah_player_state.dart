enum SurahPlayerState {
  idel,
  play,
  pause,
  loading;

  bool get isIdel => this == SurahPlayerState.idel;
}

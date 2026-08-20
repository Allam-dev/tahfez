part of 'reader_surah_list_cubit.dart';

@immutable
sealed class ReaderSurahListState {}

final class ReaderSurahListLoading extends ReaderSurahListState {}

final class ReaderSurahListLoaded extends ReaderSurahListState {
  /// Surah numbers that are fully downloaded.
  final Set<int> downloadedSurahs;

  /// Surah numbers currently downloading → progress 0.0–1.0.
  final Map<int, double> activeProgress;

  /// Whether a full-Quran batch download is running for this reader.
  final bool isFullQuranDownloading;

  ReaderSurahListLoaded({
    required this.downloadedSurahs,
    required this.activeProgress,
    required this.isFullQuranDownloading,
  });

  bool isSurahDownloaded(int surahNumber) =>
      downloadedSurahs.contains(surahNumber);

  bool isSurahDownloading(int surahNumber) =>
      activeProgress.containsKey(surahNumber);

  double surahProgress(int surahNumber) =>
      activeProgress[surahNumber] ?? 0.0;
}

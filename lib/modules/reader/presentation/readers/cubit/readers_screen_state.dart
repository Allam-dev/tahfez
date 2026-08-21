part of 'readers_screen_cubit.dart';

@immutable
sealed class ReadersScreenState {}

final class ReadersScreenLoadingState extends ReadersScreenState {}

final class ReadersScreenLoadedState extends ReadersScreenState {
  final List<ReaderModel> readers;

  /// readerId → number of downloaded surahs (0–114)
  final Map<int, int> downloadedCounts;

  /// readerId → { surahNumber → progress 0.0–1.0 }
  final Map<int, Map<int, double>> activeProgress;

  ReadersScreenLoadedState({
    required this.readers,
    required this.downloadedCounts,
    required this.activeProgress,
  });

  ReadersScreenLoadedState copyWith({
    List<ReaderModel>? readers,
    Map<int, int>? downloadedCounts,
    Map<int, Map<int, double>>? activeProgress,
  }) {
    return ReadersScreenLoadedState(
      readers: readers ?? this.readers,
      downloadedCounts: downloadedCounts ?? this.downloadedCounts,
      activeProgress: activeProgress ?? this.activeProgress,
    );
  }

  /// Average download progress across all active surahs for a reader (0.0–1.0).
  double readerOverallProgress(int readerId) {
    final perSurah = activeProgress[readerId];
    if (perSurah == null || perSurah.isEmpty) return 0.0;
    final total = perSurah.values.fold(0.0, (a, b) => a + b);
    return total / perSurah.length;
  }

  bool isReaderDownloading(int readerId) {
    final perSurah = activeProgress[readerId];
    return perSurah != null && perSurah.isNotEmpty;
  }
}

final class ReadersScreenFailureState extends ReadersScreenState {
  final Failure failure;

  ReadersScreenFailureState(this.failure);
}

part of 'readers_screen_cubit.dart';

@immutable
sealed class ReadersScreenState {}

final class ReadersScreenLoading extends ReadersScreenState {}

final class ReadersScreenLoaded extends ReadersScreenState {
  final List<ReaderModel> readers;

  /// readerId → number of downloaded surahs (0–114)
  final Map<int, int> downloadedCounts;

  /// readerId → { surahNumber → progress 0.0–1.0 }
  final Map<int, Map<int, double>> activeProgress;

  ReadersScreenLoaded({
    required this.readers,
    required this.downloadedCounts,
    required this.activeProgress,
  });

  ReadersScreenLoaded copyWith({
    List<ReaderModel>? readers,
    Map<int, int>? downloadedCounts,
    Map<int, Map<int, double>>? activeProgress,
  }) {
    return ReadersScreenLoaded(
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

final class ReadersScreenError extends ReadersScreenState {
  final Failure failure;

  ReadersScreenError(this.failure);
}

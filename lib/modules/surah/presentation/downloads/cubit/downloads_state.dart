part of 'downloads_cubit.dart';

enum DownloadsScreenStatus {
  initial,
  loading,
  loaded,
  error,
}

class DownloadingItem extends Equatable {
  final int readerId;
  final String readerName;
  final int surahNumber;
  final String surahName;
  final double progress;
  final SurahDownloadStatus status;

  const DownloadingItem({
    required this.readerId,
    required this.readerName,
    required this.surahNumber,
    required this.surahName,
    required this.progress,
    required this.status,
  });

  DownloadingItem copyWith({
    int? readerId,
    String? readerName,
    int? surahNumber,
    String? surahName,
    double? progress,
    SurahDownloadStatus? status,
  }) {
    return DownloadingItem(
      readerId: readerId ?? this.readerId,
      readerName: readerName ?? this.readerName,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        readerId,
        readerName,
        surahNumber,
        surahName,
        progress,
        status,
      ];
}

class DownloadedReaderGroup extends Equatable {
  final ReaderModel reader;
  final List<int> surahNumbers;

  const DownloadedReaderGroup({
    required this.reader,
    required this.surahNumbers,
  });

  @override
  List<Object?> get props => [reader, surahNumbers];
}

@immutable
class DownloadsState extends Equatable {
  final DownloadsScreenStatus status;
  final List<DownloadingItem> downloadingItems;
  final List<DownloadedReaderGroup> downloadedGroups;
  final Failure? failure;
  final String? message;

  const DownloadsState({
    this.status = DownloadsScreenStatus.initial,
    this.downloadingItems = const [],
    this.downloadedGroups = const [],
    this.failure,
    this.message,
  });

  DownloadsState copyWith({
    DownloadsScreenStatus? status,
    List<DownloadingItem>? downloadingItems,
    List<DownloadedReaderGroup>? downloadedGroups,
    Failure? failure,
    String? message,
  }) {
    return DownloadsState(
      status: status ?? this.status,
      downloadingItems: downloadingItems ?? this.downloadingItems,
      downloadedGroups: downloadedGroups ?? this.downloadedGroups,
      failure: failure ?? this.failure,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        downloadingItems,
        downloadedGroups,
        failure,
        message,
      ];
}

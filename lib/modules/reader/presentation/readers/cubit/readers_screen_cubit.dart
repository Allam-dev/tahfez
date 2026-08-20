import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

part 'readers_screen_state.dart';

class ReadersScreenCubit extends Cubit<ReadersScreenState> {
  final ReaderRepo _readerRepo;
  final SurahDownloader _surahDownloader;
  StreamSubscription<SurahDownloadProgress>? _progressSub;

  /// Cache of downloaded surah counts per reader, for UI display.
  final Map<int, int> _downloadedCounts = {};

  /// Per-surah progress while downloading.
  /// Key = readerId, Value = map of surahNumber → progress (0.0–1.0).
  final Map<int, Map<int, double>> _activeProgress = {};

  ReadersScreenCubit({
    required ReaderRepo readerRepo,
    required SurahDownloader surahDownloader,
  })  : _readerRepo = readerRepo,
        _surahDownloader = surahDownloader,
        super(ReadersScreenLoading()) {
    _listenToProgress();
    loadReaders();
  }

  void _listenToProgress() {
    _progressSub = _surahDownloader.downloadProgress.listen((event) {
      final readerProgress =
          _activeProgress[event.readerId] ?? {};

      switch (event.status) {
        case SurahDownloadStatus.downloading:
          readerProgress[event.surahNumber] = event.progress;
          _activeProgress[event.readerId] = readerProgress;
          break;
        case SurahDownloadStatus.completed:
          readerProgress.remove(event.surahNumber);
          _activeProgress[event.readerId] = readerProgress;
          // Increment the cached downloaded count
          _downloadedCounts[event.readerId] =
              (_downloadedCounts[event.readerId] ?? 0) + 1;
          break;
        case SurahDownloadStatus.failed:
          readerProgress.remove(event.surahNumber);
          _activeProgress[event.readerId] = readerProgress;
          break;
      }

      // Re-emit the loaded state with updated progress
      final currentState = state;
      if (currentState is ReadersScreenLoaded) {
        emit(currentState.copyWith(
          downloadedCounts: Map.from(_downloadedCounts),
          activeProgress: Map.from(_activeProgress),
        ));
      }
    });
  }

  Future<void> loadReaders() async {
    emit(ReadersScreenLoading());
    final result = await _readerRepo.getList();
    await result.fold(
      (failure) async => emit(ReadersScreenError(failure)),
      (readers) async {
        // Pre-load downloaded counts for each reader
        for (final reader in readers) {
          final downloaded =
              await _surahDownloader.getDownloadedSurahs(reader);
          _downloadedCounts[reader.id] = downloaded.length;
        }
        emit(ReadersScreenLoaded(
          readers: readers,
          downloadedCounts: Map.from(_downloadedCounts),
          activeProgress: Map.from(_activeProgress),
        ));
      },
    );
  }

  Future<void> downloadFullQuran(ReaderModel reader) async {
    await _surahDownloader.downloadFullQuran(reader);
  }

  Future<void> deleteFullQuran(ReaderModel reader) async {
    await _surahDownloader.deleteFullQuran(reader);
    _downloadedCounts[reader.id] = 0;
    _activeProgress.remove(reader.id);

    final currentState = state;
    if (currentState is ReadersScreenLoaded) {
      emit(currentState.copyWith(
        downloadedCounts: Map.from(_downloadedCounts),
        activeProgress: Map.from(_activeProgress),
      ));
    }
  }

  bool isFullQuranDownloading(int readerId) =>
      _surahDownloader.isFullQuranDownloading(readerId);

  @override
  Future<void> close() {
    _progressSub?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

part 'reader_surah_list_state.dart';

class ReaderSurahListCubit extends Cubit<ReaderSurahListState> {
  final SurahDownloader _downloader;
  final ReaderModel reader;
  StreamSubscription<SurahDownloadProgress>? _progressSub;

  ReaderSurahListCubit({
    required this.reader,
    required SurahDownloader surahDownloader,
  })  : _downloader = surahDownloader,
        super(ReaderSurahListLoading()) {
    _init();
  }

  Future<void> _init() async {
    final downloaded = await _downloader.getDownloadedSurahs(reader);
    final progressMap = <int, double>{};

    emit(ReaderSurahListLoaded(
      downloadedSurahs: downloaded,
      activeProgress: progressMap,
      isFullQuranDownloading: _downloader.isFullQuranDownloading(reader.id),
    ));

    _progressSub = _downloader.downloadProgress.listen((event) {
      if (event.readerId != reader.id) return;

      final currentState = state;
      if (currentState is! ReaderSurahListLoaded) return;

      final newDownloaded = Set<int>.from(currentState.downloadedSurahs);
      final newProgress = Map<int, double>.from(currentState.activeProgress);

      switch (event.status) {
        case SurahDownloadStatus.downloading:
          newProgress[event.surahNumber] = event.progress;
          break;
        case SurahDownloadStatus.completed:
          newProgress.remove(event.surahNumber);
          newDownloaded.add(event.surahNumber);
          break;
        case SurahDownloadStatus.failed:
          newProgress.remove(event.surahNumber);
          break;
      }

      emit(ReaderSurahListLoaded(
        downloadedSurahs: newDownloaded,
        activeProgress: newProgress,
        isFullQuranDownloading:
            _downloader.isFullQuranDownloading(reader.id),
      ));
    });
  }

  Future<void> downloadSurah(int surahNumber) async {
    await _downloader.downloadSurah(reader, surahNumber);
  }

  Future<void> deleteSurah(int surahNumber) async {
    await _downloader.deleteSurah(reader, surahNumber);

    final currentState = state;
    if (currentState is ReaderSurahListLoaded) {
      final newDownloaded = Set<int>.from(currentState.downloadedSurahs)
        ..remove(surahNumber);
      emit(ReaderSurahListLoaded(
        downloadedSurahs: newDownloaded,
        activeProgress: Map.from(currentState.activeProgress),
        isFullQuranDownloading: currentState.isFullQuranDownloading,
      ));
    }
  }

  bool get isFullQuranDownloading =>
      _downloader.isFullQuranDownloading(reader.id);

  @override
  Future<void> close() {
    _progressSub?.cancel();
    return super.close();
  }
}

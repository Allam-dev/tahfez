import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';
import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';

part 'downloads_state.dart';

class DownloadsCubit extends Cubit<DownloadsState> {
  final SurahDownloader _downloader;
  final ReaderRepo _readerRepo;

  StreamSubscription<SurahDownloadProgress>? _progressSubscription;
  List<ReaderModel> _cachedReaders = [];

  DownloadsCubit(this._downloader, this._readerRepo)
      : super(const DownloadsState()) {
    _init();
  }

  Future<void> _init() async {
    await loadData();
    _subscribeToProgress();
  }

  void _subscribeToProgress() {
    _progressSubscription = _downloader.downloadProgress.listen((progress) {
      _handleProgressUpdate(progress);
    });
  }

  Future<void> loadData() async {
    emit(state.copyWith(status: DownloadsScreenStatus.loading));
    try {
      final readersResult = await _readerRepo.getList();
      readersResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: DownloadsScreenStatus.error,
              failure: failure,
            ),
          );
        },
        (readers) async {
          _cachedReaders = readers;
          await _loadDownloadedGroups();
          emit(state.copyWith(status: DownloadsScreenStatus.loaded));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadsScreenStatus.error,
          failure: Failure.fromException(e),
        ),
      );
    }
  }

  Future<void> _loadDownloadedGroups() async {
    await QuranAudioResolver.init();
    final downloadedGroups = <DownloadedReaderGroup>[];

    for (final reader in _cachedReaders) {
      final downloadedSurahsSet = await _downloader.getDownloadedSurahs(reader);
      if (downloadedSurahsSet.isNotEmpty) {
        final sortedSurahs = downloadedSurahsSet.toList()..sort();
        downloadedGroups.add(
          DownloadedReaderGroup(
            reader: reader,
            surahNumbers: sortedSurahs,
          ),
        );
      }
    }

    emit(state.copyWith(downloadedGroups: downloadedGroups));
  }

  void _handleProgressUpdate(SurahDownloadProgress progress) {
    final reader = _cachedReaders.firstWhere(
      (r) => r.id == progress.readerId,
      orElse: () => ReaderModel(
        id: progress.readerId,
        name: 'Reader #${progress.readerId}',
        rewaya: '',
        downloadUrl: '',
      ),
    );

    final surahName = (progress.surahNumber > 0 && progress.surahNumber <= SUR.length)
        ? SUR[progress.surahNumber - 1].name
        : 'Surah #${progress.surahNumber}';

    final updatedDownloadingItems = List<DownloadingItem>.from(state.downloadingItems);

    final index = updatedDownloadingItems.indexWhere(
      (item) => item.readerId == progress.readerId && item.surahNumber == progress.surahNumber,
    );

    if (progress.status == SurahDownloadStatus.completed) {
      if (index != -1) {
        updatedDownloadingItems.removeAt(index);
      }
      _loadDownloadedGroups();
    } else {
      final item = DownloadingItem(
        readerId: progress.readerId,
        readerName: reader.nameWithRewaya,
        surahNumber: progress.surahNumber,
        surahName: surahName,
        progress: progress.progress,
        status: progress.status,
      );

      if (index != -1) {
        updatedDownloadingItems[index] = item;
      } else {
        updatedDownloadingItems.add(item);
      }
    }

    emit(state.copyWith(downloadingItems: updatedDownloadingItems));
  }

  Future<void> retryDownload(DownloadingItem item) async {
    final reader = _cachedReaders.firstWhere(
      (r) => r.id == item.readerId,
      orElse: () => ReaderModel(
        id: item.readerId,
        name: item.readerName,
        rewaya: '',
        downloadUrl: '',
      ),
    );

    // Reset status in downloading items
    final updatedList = state.downloadingItems.map((e) {
      if (e.readerId == item.readerId && e.surahNumber == item.surahNumber) {
        return e.copyWith(status: SurahDownloadStatus.downloading, progress: 0.0);
      }
      return e;
    }).toList();

    emit(state.copyWith(downloadingItems: updatedList));

    try {
      await _downloader.downloadSurah(reader, item.surahNumber);
    } catch (e) {
      emit(
        state.copyWith(
          failure: Failure.fromException(e),
        ),
      );
    }
  }

  Future<void> deleteSurah(ReaderModel reader, int surahNumber) async {
    try {
      await _downloader.deleteSurah(reader, surahNumber);
      await _loadDownloadedGroups();
      emit(state.copyWith(message: LocaleKeys.deletedSuccessfully));
    } catch (e) {
      emit(state.copyWith(failure: Failure.fromException(e)));
    }
  }

  Future<void> deleteReaderDownloads(ReaderModel reader) async {
    try {
      await _downloader.deleteFullQuran(reader);
      await _loadDownloadedGroups();
      emit(state.copyWith(message: LocaleKeys.deletedSuccessfully));
    } catch (e) {
      emit(state.copyWith(failure: Failure.fromException(e)));
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}

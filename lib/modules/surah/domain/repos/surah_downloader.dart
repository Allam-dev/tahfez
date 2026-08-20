import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';

abstract class SurahDownloader {
  /// Downloads a single surah for the given reader.
  /// Skips if the file already exists on disk.
  /// Throws if a full-Quran download is in progress for this reader.
  Future<void> downloadSurah(ReaderModel reader, int surahNumber);

  /// Downloads all 114 surahs for the given reader.
  /// Skips surahs that are already downloaded or currently downloading.
  Future<void> downloadFullQuran(ReaderModel reader);

  /// Deletes a single downloaded surah file.
  Future<void> deleteSurah(ReaderModel reader, int surahNumber);

  /// Deletes all downloaded surahs for a reader.
  Future<void> deleteFullQuran(ReaderModel reader);

  /// Returns true if the surah file exists on disk.
  Future<bool> isSurahDownloaded(ReaderModel reader, int surahNumber);

  /// Returns the set of surah numbers that are downloaded for a reader.
  Future<Set<int>> getDownloadedSurahs(ReaderModel reader);

  /// Whether a full-Quran download is currently running for the given reader.
  bool isFullQuranDownloading(int readerId);

  /// A broadcast stream of per-surah download progress events.
  Stream<SurahDownloadProgress> get downloadProgress;
}
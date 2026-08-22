import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

abstract class QuranAudioResolver {
  static String? _basePath;

  /// Relative directory path within applicationSupport for background_downloader (e.g. 'quran_audio/42').
  static String relativeReaderDir(int readerId) => 'quran_audio/$readerId';

  /// Standardized filename for a surah, e.g., "001.mp3".
  static String surahFileName(int surahNumber) =>
      '${surahNumber.toString().padLeft(3, '0')}.mp3';

  /// Absolute base path to quran_audio directory in application support.
  static Future<String> init() async {
    if (_basePath != null) return _basePath!;
    final dir = await getApplicationSupportDirectory();
    _basePath = '${dir.path}/quran_audio';
    return _basePath!;
  }

  /// Absolute directory path for a reader's audio files (e.g. '/app_support/quran_audio/42').
  static Future<String> readerDir(int readerId) async {
    return '$_basePath/$readerId';
  }

  /// Absolute file path for a specific surah of a reader.
  static Future<String> localFilePath(int readerId, int surahNumber) async {
    return '$_basePath/$readerId/${surahFileName(surahNumber)}';
  }

  /// Checks if a surah audio file exists locally on disk (Async).
  static Future<bool> isDownloaded(int readerId, int surahNumber) async {
    final path = await localFilePath(readerId, surahNumber);
    return File(path).existsSync();
  }

  /// Synchronous check using cached basePath if available.
  static bool isDownloadedSync(int readerId, int surahNumber) {
    if (_basePath == null) return false;
    final path = '$_basePath/$readerId/${surahFileName(surahNumber)}';
    return File(path).existsSync();
  }

  /// Returns `file://` URI if downloaded locally, otherwise `https://` remote URL.
  static Future<Uri> playbackUri(ReaderModel reader, int surahNumber) async {
    final path = await localFilePath(reader.id, surahNumber);
    if (File(path).existsSync()) {
      return Uri.file(path);
    }
    return Uri.parse('${reader.downloadUrl}${surahFileName(surahNumber)}');
  }
}

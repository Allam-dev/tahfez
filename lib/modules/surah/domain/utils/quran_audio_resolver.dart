import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';

abstract class QuranAudioResolver {
  static String? _cachedBasePath;

  /// Relative subdirectory within applicationSupport for a reader.
  static String readerSubDir(int readerId) => 'quran_audio/$readerId';

  /// Standardized filename for a surah, e.g., "001.mp3".
  static String surahFileName(int surahNumber) =>
      '${surahNumber.toString().padLeft(3, '0')}.mp3';

  /// Absolute base path to quran_audio directory in application support.
  static Future<String> basePath() async {
    if (_cachedBasePath != null) return _cachedBasePath!;
    final dir = await getApplicationSupportDirectory();
    _cachedBasePath = '${dir.path}/quran_audio';
    return _cachedBasePath!;
  }

  /// Absolute directory path for a reader's audio files.
  static Future<String> readerDir(int readerId) async {
    final base = await basePath();
    return '$base/$readerId';
  }

  /// Absolute file path for a specific surah of a reader.
  static Future<String> localFilePath(int readerId, int surahNumber) async {
    final base = await basePath();
    return '$base/$readerId/${surahFileName(surahNumber)}';
  }

  /// Checks if a surah audio file exists locally on disk.
  static Future<bool> isDownloaded(int readerId, int surahNumber) async {
    final path = await localFilePath(readerId, surahNumber);
    return File(path).existsSync();
  }

  /// Synchronous check if base path is already cached.
  static bool isDownloadedSync(
      String basePath, int readerId, int surahNumber) {
    final path = '$basePath/$readerId/${surahFileName(surahNumber)}';
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

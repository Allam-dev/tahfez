import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

class SurahDownloaderBackgroundDownloaderImpl implements SurahDownloader {
  static const _group = 'quran_download';

  final StreamController<SurahDownloadProgress> _progressController =
      StreamController<SurahDownloadProgress>.broadcast();

  /// Readers whose full-Quran download is currently in flight.
  final Set<int> _fullQuranInProgress = {};

  /// Tracks how many surahs remain for each full-Quran batch.
  final Map<int, int> _fullQuranRemaining = {};

  /// Surahs currently being downloaded individually (not as part of full Quran).
  /// Key = "$readerId-$surahNumber"
  final Set<String> _individualInProgress = {};

  /// Tracks which tasks are part of a full-Quran batch.
  /// Key = taskId, Value = true if part of full Quran.
  final Map<String, bool> _taskIsFullQuran = {};

  /// Cached base path to avoid repeated async calls.
  String? _cachedBasePath;

  static final SurahDownloaderBackgroundDownloaderImpl instance =
      SurahDownloaderBackgroundDownloaderImpl._();

  SurahDownloaderBackgroundDownloaderImpl._();

  // ──────────────────────────────────────────────────────────
  // Initialization — MUST be called before FileDownloader().start()
  // ──────────────────────────────────────────────────────────

  /// Call this before FileDownloader().start() in main.dart.
  /// Sets up foreground service, notification config, and the
  /// updates listener so background events that fired while the
  /// app was suspended are properly received.
  Future<void> initialize() async {
    // Request notification permission (required on Android 13+ / API 33+).
    // On older versions this is a no-op.
    final status = await FileDownloader().permissions.status(
      PermissionType.notifications,
    );
    if (status != PermissionStatus.granted) {
      await FileDownloader().permissions.request(PermissionType.notifications);
    }

    // Run downloads as an Android foreground service so they survive
    // app closure and have no 9-minute WorkManager time limit.
    // Limit concurrent downloads to 3 to avoid overwhelming the network.
    await FileDownloader().configure(
      androidConfig: [(Config.runInForeground, Config.always)],
      globalConfig: [(Config.holdingQueue, (3, null, null))],
    );

    // Configure notifications for download tasks
    FileDownloader().configureNotification(
      running: const TaskNotification('جاري تحميل القرآن', '{filename}'),
      complete: const TaskNotification('اكتمل التحميل', '{filename}'),
      error: const TaskNotification('فشل التحميل', '{filename}'),
      progressBar: true,
    );

    // Register update listener — must be before start()
    FileDownloader().updates.listen((update) {
      // Only handle tasks from our group
      if (update.task.group != _group) return;

      final parsed = _parseTaskId(update.task.taskId);
      if (parsed == null) return;
      final (readerId, surahNumber) = parsed;

      if (update is TaskProgressUpdate) {
        _progressController.add(
          SurahDownloadProgress(
            readerId: readerId,
            surahNumber: surahNumber,
            progress: update.progress,
            status: SurahDownloadStatus.downloading,
          ),
        );
      } else if (update is TaskStatusUpdate) {
        _handleStatusUpdate(update, readerId, surahNumber);
      }
    });

    await FileDownloader().start(autoCleanDatabase: true);
  }

  void _handleStatusUpdate(
    TaskStatusUpdate update,
    int readerId,
    int surahNumber,
  ) {
    if (update.status == TaskStatus.complete) {
      _progressController.add(
        SurahDownloadProgress(
          readerId: readerId,
          surahNumber: surahNumber,
          progress: 1.0,
          status: SurahDownloadStatus.completed,
        ),
      );
      _onDownloadFinished(readerId, surahNumber, update.task.taskId);
    } else if (update.status == TaskStatus.failed ||
        update.status == TaskStatus.notFound || update.status == TaskStatus.canceled) {
      _progressController.add(
        SurahDownloadProgress(
          readerId: readerId,
          surahNumber: surahNumber,
          progress: 0.0,
          status: SurahDownloadStatus.failed,
        ),
      );
      _onDownloadFinished(readerId, surahNumber, update.task.taskId);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  /// Parses a taskId like "quran_42_003" → (readerId=42, surahNumber=3).
  static (int readerId, int surahNumber)? _parseTaskId(String taskId) {
    final parts = taskId.split('_');
    if (parts.length != 3 || parts[0] != 'quran') return null;
    final readerId = int.tryParse(parts[1]);
    final surahNumber = int.tryParse(parts[2]);
    if (readerId == null || surahNumber == null) return null;
    return (readerId, surahNumber);
  }

  /// Returns the app-private base directory for quran audio.
  Future<String> _basePath() async {
    if (_cachedBasePath != null) return _cachedBasePath!;
    final dir = await getApplicationSupportDirectory();
    _cachedBasePath = '${dir.path}/quran_audio';
    return _cachedBasePath!;
  }

  /// Relative subdirectory within applicationSupport for a reader.
  String _readerSubDir(int readerId) => 'quran_audio/$readerId';

  /// Returns the absolute directory path for a specific reader.
  String _readerDir(String basePath, int readerId) => '$basePath/$readerId';

  /// Returns the absolute file path for a specific surah of a reader.
  String _surahPath(String basePath, int readerId, int surahNumber) {
    final fileName = surahNumber.toString().padLeft(3, '0');
    return '${_readerDir(basePath, readerId)}/$fileName.mp3';
  }

  /// Builds the download URL for a surah.
  String _surahUrl(ReaderModel reader, int surahNumber) {
    final fileName = surahNumber.toString().padLeft(3, '0');
    return '${reader.downloadUrl}$fileName.mp3';
  }

  /// Unique task ID for background_downloader.
  String _taskId(int readerId, int surahNumber) =>
      'quran_${readerId}_${surahNumber.toString().padLeft(3, '0')}';

  // ──────────────────────────────────────────────────────────
  // Download single surah
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> downloadSurah(ReaderModel reader, int surahNumber) async {
    // Block if full-Quran download is running for this reader
    if (_fullQuranInProgress.contains(reader.id)) {
      return;
    }

    final basePath = await _basePath();
    final filePath = _surahPath(basePath, reader.id, surahNumber);

    // Skip if already downloaded
    if (File(filePath).existsSync()) return;

    // Skip if already downloading individually
    final key = '${reader.id}-$surahNumber';
    if (_individualInProgress.contains(key)) return;
    _individualInProgress.add(key);

    await _enqueueDownload(
      reader: reader,
      surahNumber: surahNumber,
      isPartOfFullQuran: false,
    );
  }

  // ──────────────────────────────────────────────────────────
  // Download full Quran
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> downloadFullQuran(ReaderModel reader) async {
    if (_fullQuranInProgress.contains(reader.id)) return;

    _fullQuranInProgress.add(reader.id);
    final basePath = await _basePath();

    // Determine which surahs actually need downloading
    final toDownload = <int>[];
    for (int i = 1; i <= 114; i++) {
      final filePath = _surahPath(basePath, reader.id, i);
      final key = '${reader.id}-$i';

      // Skip if already on disk
      if (File(filePath).existsSync()) continue;

      // Skip if already downloading individually — let it finish on its own
      if (_individualInProgress.contains(key)) continue;

      toDownload.add(i);
    }

    if (toDownload.isEmpty) {
      _fullQuranInProgress.remove(reader.id);
      return;
    }

    _fullQuranRemaining[reader.id] = toDownload.length;

    // Use enqueueAll for efficiency with many tasks
    final tasks = <DownloadTask>[];
    for (final surahNumber in toDownload) {
      final taskId = _taskId(reader.id, surahNumber);
      _taskIsFullQuran[taskId] = true;

      tasks.add(
        DownloadTask(
          taskId: taskId,
          url: _surahUrl(reader, surahNumber),
          filename: '${surahNumber.toString().padLeft(3, '0')}.mp3',
          directory: _readerSubDir(reader.id),
          baseDirectory: BaseDirectory.applicationSupport,
          group: _group,
          updates: Updates.statusAndProgress,
          requiresWiFi: false,
          retries: 5,
          allowPause: true,
        ),
      );
    }

    await FileDownloader().enqueueAll(tasks);
  }

  // ──────────────────────────────────────────────────────────
  // Core download logic — uses enqueue() for true background
  // ──────────────────────────────────────────────────────────

  Future<void> _enqueueDownload({
    required ReaderModel reader,
    required int surahNumber,
    required bool isPartOfFullQuran,
  }) async {
    final taskId = _taskId(reader.id, surahNumber);

    // Track whether this task is part of full-Quran batch
    _taskIsFullQuran[taskId] = isPartOfFullQuran;

    final task = DownloadTask(
      taskId: taskId,
      url: _surahUrl(reader, surahNumber),
      filename: '${surahNumber.toString().padLeft(3, '0')}.mp3',
      directory: _readerSubDir(reader.id),
      baseDirectory: BaseDirectory.applicationSupport,
      group: _group,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
    );

    await FileDownloader().enqueue(task);
  }

  void _onDownloadFinished(int readerId, int surahNumber, String taskId) {
    final key = '$readerId-$surahNumber';
    _individualInProgress.remove(key);

    final isPartOfFullQuran = _taskIsFullQuran.remove(taskId) ?? false;

    if (isPartOfFullQuran) {
      final remaining = (_fullQuranRemaining[readerId] ?? 1) - 1;
      if (remaining <= 0) {
        _fullQuranInProgress.remove(readerId);
        _fullQuranRemaining.remove(readerId);
      } else {
        _fullQuranRemaining[readerId] = remaining;
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // Delete
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> deleteSurah(ReaderModel reader, int surahNumber) async {
    final basePath = await _basePath();
    final file = File(_surahPath(basePath, reader.id, surahNumber));
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteFullQuran(ReaderModel reader) async {
    final basePath = await _basePath();
    final dir = Directory(_readerDir(basePath, reader.id));
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Query
  // ──────────────────────────────────────────────────────────

  @override
  Future<bool> isSurahDownloaded(ReaderModel reader, int surahNumber) async {
    final basePath = await _basePath();
    return File(_surahPath(basePath, reader.id, surahNumber)).existsSync();
  }

  @override
  Future<Set<int>> getDownloadedSurahs(ReaderModel reader) async {
    final basePath = await _basePath();
    final dir = Directory(_readerDir(basePath, reader.id));
    if (!dir.existsSync()) return {};

    final downloaded = <int>{};
    for (final entity in dir.listSync()) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        // Parse "001.mp3" → 1
        final numberStr = name.replaceAll('.mp3', '');
        final number = int.tryParse(numberStr);
        if (number != null) {
          downloaded.add(number);
        }
      }
    }
    return downloaded;
  }

  @override
  bool isFullQuranDownloading(int readerId) =>
      _fullQuranInProgress.contains(readerId);

  @override
  Stream<SurahDownloadProgress> get downloadProgress =>
      _progressController.stream;
}

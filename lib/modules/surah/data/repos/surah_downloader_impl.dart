import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/data/data_sources/api/surah_api.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_download_progress.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

import 'package:tahfez/modules/surah/domain/utils/quran_audio_resolver.dart';

class SurahDownloaderBackgroundDownloaderImpl implements SurahDownloader {
  static const _group = 'quran_download';
  static const _batchSize = 5;

  final SurahAPI _surahApi;

  final StreamController<SurahDownloadProgress> _progressController =
      StreamController<SurahDownloadProgress>.broadcast();

  /// Readers whose batch (range / full-Quran) download is currently in flight.
  final Set<int> _batchInProgress = {};

  /// Tracks how many surahs remain for each batch download.
  final Map<int, int> _batchRemaining = {};

  /// Surahs currently being downloaded individually (not as part of a batch).
  /// Key = "$readerId-$surahNumber"
  final Set<String> _individualInProgress = {};

  /// Tracks which tasks are part of a batch download.
  /// Key = taskId, Value = true if part of a batch.
  final Map<String, bool> _taskIsBatch = {};

  static final SurahDownloaderBackgroundDownloaderImpl instance =
      SurahDownloaderBackgroundDownloaderImpl._();

  SurahDownloaderBackgroundDownloaderImpl._({SurahAPI? surahApi})
    : _surahApi = surahApi ?? SurahAPI();

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
      running: const TaskNotification('جاري تحميل {displayName}', '{metaData}'),
      complete: const TaskNotification('اكتمل التحميل {displayName}', '{metaData}'),
      error: const TaskNotification('فشل التحميل {displayName}', '{metaData}'),
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
        _notifyProgress(
          readerId,
          surahNumber,
          update.progress,
          SurahDownloadStatus.downloading,
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
      _notifyProgress(
        readerId,
        surahNumber,
        1.0,
        SurahDownloadStatus.completed,
      );
      _onDownloadFinished(readerId, surahNumber, update.task.taskId);
    } else if (update.status == TaskStatus.failed ||
        update.status == TaskStatus.notFound ||
        update.status == TaskStatus.canceled) {
      _notifyProgress(readerId, surahNumber, 0.0, SurahDownloadStatus.failed);
      _onDownloadFinished(readerId, surahNumber, update.task.taskId);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helpers & Clean Factories
  // ──────────────────────────────────────────────────────────

  String _surahKey(int readerId, int surahNumber) => '$readerId-$surahNumber';

  void _notifyProgress(
    int readerId,
    int surahNumber,
    double progress,
    SurahDownloadStatus status,
  ) {
    _progressController.add(
      SurahDownloadProgress(
        readerId: readerId,
        surahNumber: surahNumber,
        progress: progress,
        status: status,
      ),
    );
  }

  DownloadTask _createTask(ReaderModel reader, int surahNumber) {
    return DownloadTask(
      taskId: _taskId(reader.id, surahNumber),
      url: _surahUrl(reader, surahNumber),
      filename: QuranAudioResolver.surahFileName(surahNumber),
      directory: QuranAudioResolver.relativeReaderDir(reader.id),
      baseDirectory: BaseDirectory.applicationSupport,
      group: _group,
      updates: Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
      displayName: SUR[surahNumber - 1].name,
      metaData: '${reader.name} - ${reader.rewaya}',
    );
  }

  /// Parses a taskId like "quran_42_003.mp3" or "quran_42_003" → (readerId=42, surahNumber=3).
  static (int readerId, int surahNumber)? _parseTaskId(String taskId) {
    final parts = taskId.split('_');
    if (parts.length != 3 || parts[0] != 'quran') return null;
    final readerId = int.tryParse(parts[1]);
    final cleanSurahStr = parts[2].replaceAll('.mp3', '');
    final surahNumber = int.tryParse(cleanSurahStr);
    if (readerId == null || surahNumber == null) return null;
    return (readerId, surahNumber);
  }

  /// Builds the download URL for a surah.
  String _surahUrl(ReaderModel reader, int surahNumber) {
    return '${reader.downloadUrl}${QuranAudioResolver.surahFileName(surahNumber)}';
  }

  /// Unique task ID for background_downloader.
  String _taskId(int readerId, int surahNumber) =>
      'quran_${readerId}_${QuranAudioResolver.surahFileName(surahNumber)}';

  // ──────────────────────────────────────────────────────────
  // Download single surah
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> downloadSurah(ReaderModel reader, int surahNumber) async {
    // Block if a batch download is running for this reader
    if (_batchInProgress.contains(reader.id)) {
      return;
    }

    // Skip if already downloaded
    if (QuranAudioResolver.isDownloadedSync(reader.id, surahNumber)) return;

    // Skip if already downloading individually
    final key = _surahKey(reader.id, surahNumber);
    if (_individualInProgress.contains(key)) return;
    _individualInProgress.add(key);

    _notifyProgress(
      reader.id,
      surahNumber,
      0.0,
      SurahDownloadStatus.downloading,
    );

    // Step 1: Fetch and cache surah timing data
    try {
      await _surahApi.getTiming(surahNumber, reader.id);
    } catch (e) {
      _individualInProgress.remove(key);
      _notifyProgress(reader.id, surahNumber, 0.0, SurahDownloadStatus.failed);
      return;
    }

    // Step 2: Enqueue audio download
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
  Future<void> downloadFullQuran(ReaderModel reader) =>
      downloadRange(reader, 1, 114);

  @override
  Future<void> downloadRange(
    ReaderModel reader,
    int startSurahNumber,
    int endSurahNumber,
  ) async {
    if (_batchInProgress.contains(reader.id)) return;

    _batchInProgress.add(reader.id);

    final toDownload = _getSurahsToDownloadInRange(
      reader,
      startSurahNumber,
      endSurahNumber,
    );
    if (toDownload.isEmpty) {
      _batchInProgress.remove(reader.id);
      return;
    }

    final tasksToEnqueue = await _prepareBatchTasks(reader, toDownload);

    if (tasksToEnqueue.isEmpty) {
      _batchInProgress.remove(reader.id);
      _batchRemaining.remove(reader.id);
      return;
    }

    _batchRemaining[reader.id] = tasksToEnqueue.length;
    await FileDownloader().enqueueAll(tasksToEnqueue);
  }

  List<int> _getSurahsToDownloadInRange(
    ReaderModel reader,
    int start,
    int end,
  ) {
    final toDownload = <int>[];
    for (int i = start; i <= end; i++) {
      final isDownloaded = QuranAudioResolver.isDownloadedSync(reader.id, i);
      final key = _surahKey(reader.id, i);

      // Skip if already on disk
      if (isDownloaded) continue;

      // Skip if already downloading individually — let it finish on its own
      if (_individualInProgress.contains(key)) continue;

      toDownload.add(i);
    }
    return toDownload;
  }

  Future<List<DownloadTask>> _prepareBatchTasks(
    ReaderModel reader,
    List<int> toDownload,
  ) async {
    final tasksToEnqueue = <DownloadTask>[];

    for (int i = 0; i < toDownload.length; i += _batchSize) {
      if (!_batchInProgress.contains(reader.id)) break;

      final chunk = toDownload.sublist(
        i,
        i + _batchSize > toDownload.length ? toDownload.length : i + _batchSize,
      );

      await Future.wait(
        chunk.map(
          (surahNumber) =>
              _processBatchSurah(reader, surahNumber, tasksToEnqueue),
        ),
      );
    }

    return tasksToEnqueue;
  }

  Future<void> _processBatchSurah(
    ReaderModel reader,
    int surahNumber,
    List<DownloadTask> tasksToEnqueue,
  ) async {
    _notifyProgress(
      reader.id,
      surahNumber,
      0.0,
      SurahDownloadStatus.downloading,
    );
    final taskId = _taskId(reader.id, surahNumber);

    try {
      await _surahApi.getTiming(surahNumber, reader.id);
      _taskIsBatch[taskId] = true;
      tasksToEnqueue.add(_createTask(reader, surahNumber));
    } catch (e) {
      _notifyProgress(reader.id, surahNumber, 0.0, SurahDownloadStatus.failed);
    }
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

    // Track whether this task is part of a batch download
    _taskIsBatch[taskId] = isPartOfFullQuran;

    await FileDownloader().enqueue(_createTask(reader, surahNumber));
  }

  void _onDownloadFinished(int readerId, int surahNumber, String taskId) {
    final key = _surahKey(readerId, surahNumber);
    _individualInProgress.remove(key);

    final isPartOfBatch = _taskIsBatch.remove(taskId) ?? false;

    if (isPartOfBatch) {
      final remaining = (_batchRemaining[readerId] ?? 1) - 1;
      if (remaining <= 0) {
        _batchInProgress.remove(readerId);
        _batchRemaining.remove(readerId);
      } else {
        _batchRemaining[readerId] = remaining;
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // Delete
  // ──────────────────────────────────────────────────────────

  @override
  Future<void> deleteSurah(ReaderModel reader, int surahNumber) async {
    final path = await QuranAudioResolver.localFilePath(reader.id, surahNumber);
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteFullQuran(ReaderModel reader) async {
    final readerDirPath = await QuranAudioResolver.readerDir(reader.id);
    final dir = Directory(readerDirPath);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Query
  // ──────────────────────────────────────────────────────────

  @override
  Future<bool> isSurahDownloaded(ReaderModel reader, int surahNumber) async {
    return QuranAudioResolver.isDownloaded(reader.id, surahNumber);
  }

  @override
  Future<Set<int>> getDownloadedSurahs(ReaderModel reader) async {
    final readerDirPath = await QuranAudioResolver.readerDir(reader.id);
    final dir = Directory(readerDirPath);
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
      _batchInProgress.contains(readerId);

  @override
  Stream<SurahDownloadProgress> get downloadProgress =>
      _progressController.stream;
}

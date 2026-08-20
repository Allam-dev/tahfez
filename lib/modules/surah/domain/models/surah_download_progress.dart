import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';

class SurahDownloadProgress {
  final int readerId;
  final int surahNumber;
  final double progress;
  final SurahDownloadStatus status;

  const SurahDownloadProgress({
    required this.readerId,
    required this.surahNumber,
    required this.progress,
    required this.status,
  });
}

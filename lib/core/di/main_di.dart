import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:tahfez/core/services/download_manager/download_manager.dart';
import 'package:tahfez/core/services/download_manager/download_manager_dio_imp.dart';
import 'package:tahfez/core/services/token/token_handler.dart';
import 'package:tahfez/core/services/token/token_handler_impl.dart';
import 'package:tahfez/modules/reader/data/repos/reader_repo_impl.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

import 'package:tahfez/modules/reader/presentation/readers/cubit/readers_screen_cubit.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

final getIt = GetIt.instance;

void initDI(AudioHandler audioHandler, SurahDownloader surahDownloader) {
  getIt.registerLazySingleton<TokenHandler>(() => TokenHandlerImpl());

  getIt.registerLazySingleton<DownloadManager>(() => DownloadManagerDioImp());

  // The audioHandler IS a SurahPlayer (SurahPlayerJustAudioImpl extends
  // BaseAudioHandler and implements SurahPlayer). Registered as singleton
  // because the handler lives in the foreground service and must persist.
  getIt.registerSingleton<SurahPlayer>(audioHandler as SurahPlayer);

  getIt.registerFactory<ReaderRepo>(() => ReaderRepoImpl());

  // Register the pre-created downloader instance whose listener was
  // registered before FileDownloader().start() in main.dart.
  getIt.registerSingleton<SurahDownloader>(surahDownloader);

  getIt.registerFactory<ReadersScreenCubit>(
    () => ReadersScreenCubit(
      readerRepo: getIt<ReaderRepo>(),
      surahDownloader: getIt<SurahDownloader>(),
    ),
  );
}

import 'package:get_it/get_it.dart';
import 'package:tahfez/core/services/download_manager/download_manager.dart';
import 'package:tahfez/core/services/download_manager/download_manager_dio_imp.dart';
import 'package:tahfez/core/services/token/token_handler.dart';
import 'package:tahfez/core/services/token/token_handler_impl.dart';
import 'package:tahfez/modules/reader/data/repos/reader_repo_impl.dart';
import 'package:tahfez/modules/surah/data/repos/surah_downloader_impl.dart';
import 'package:tahfez/modules/surah/data/repos/surah_player_just_audio_impl.dart';
import 'package:tahfez/modules/surah/domain/surah_player.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';

final getIt = GetIt.instance;

void initDI() {
  getIt.registerLazySingleton<TokenHandler>(() => TokenHandlerImpl());

  getIt.registerLazySingleton<DownloadManager>(() => DownloadManagerDioImp());

  getIt.registerSingleton<SurahPlayer>(SurahPlayerJustAudioImpl.instance);

  getIt.registerFactory<ReaderRepo>(() => ReaderRepoImpl());

  getIt.registerSingleton<SurahDownloader>(
    SurahDownloaderBackgroundDownloaderImpl.instance,
  );

}

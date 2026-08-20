import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/app/app.dart';
import 'package:tahfez/app/localization/localization_constants.dart';
import 'package:tahfez/core/data/sources/local/hive/hive_helper.dart';
import 'package:tahfez/core/data/sources/remote/api/dio_factor.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/surah/data/repos/surah_player_just_audio_impl.dart';
import 'package:tahfez/modules/surah/data/repos/surah_downloader_impl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_downloader/background_downloader.dart';

Future<void> _appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
  }

  // 1. Create the downloader singleton FIRST
  final surahDownloader = SurahDownloaderImpl();

  // 2. Configure notifications & register update listener
  //    BEFORE calling start() — per background_downloader docs,
  //    the listener must be registered before start() to receive
  //    events from tasks that completed while the app was suspended.
  surahDownloader.initialize();

  // 3. NOW start the FileDownloader (triggers processing of
  //    background events queued while app was closed)
  await FileDownloader().start(autoCleanDatabase: true);

  await HiveHelper.init();
  final storageDirectory = kIsWeb
      ? HydratedStorageDirectory.web
      : HydratedStorageDirectory((await getTemporaryDirectory()).path);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: storageDirectory,
  );

  await DioFactory.instance.init();
  // Initialize audio_service — creates the foreground service that
  // keeps the Dart isolate alive even when the app is closed.
  final audioHandler = await AudioService.init(
    builder: () => SurahPlayerJustAudioImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'tahfez.allam.labs',
      androidNotificationChannelName: 'Quran Playback',
      androidStopForegroundOnPause: false,
    ),
  );

  // 4. Register all dependencies — pass the already-created downloader
  initDI(audioHandler, surahDownloader);

  await Future.wait<dynamic>([
    ScreenUtil.ensureScreenSize(),
    EasyLocalization.ensureInitialized(),
  ]);
}

void main() async {
  await _appInit();

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationConstants.supportedLocales,
      path: LocalizationConstants.assetsPath,
      fallbackLocale: LocalizationConstants.fallbackLocale,
      startLocale: LocalizationConstants.defaultLocale,
      child: App(),
    ),
  );
}

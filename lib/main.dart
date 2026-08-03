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
import 'package:path_provider/path_provider.dart';

Future<void> _appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
  }

  initDI();
  await HiveHelper.init();
  final storageDirectory = kIsWeb
      ? HydratedStorageDirectory.web
      : HydratedStorageDirectory((await getTemporaryDirectory()).path);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: storageDirectory,
  );

  await Future.wait<dynamic>([
    ScreenUtil.ensureScreenSize(),
    EasyLocalization.ensureInitialized(),
  ]);
  await DioFactory.instance.init();
}

void main() async {
  await _appInit();

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationConstants.supportedLocales,
      path: LocalizationConstants.assetsPath,
      fallbackLocale: LocalizationConstants.fallbackLocale,
      child: App(),
    ),
  );
}

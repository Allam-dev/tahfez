import 'package:tahfez/app/style/theme/dark_theme.dart';
import 'package:tahfez/app/style/theme/light_theme.dart';
import 'package:tahfez/app/style/theme/theme_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/modules/surah/presentation/play_settings/play_settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(),
        child: Builder(
          builder: (context) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, state) => MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                themeMode: state,
                theme: LIGHT_THEME,
                darkTheme: DARK_THEME,
                home: PlaySettingsScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

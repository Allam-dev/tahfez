import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/app/style/theme/theme_cubit.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => TextTheme.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  void setThemeMode(ThemeMode mode) {
    read<ThemeCubit>().setMode(mode);
  }
}

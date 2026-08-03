import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setMode(ThemeMode mode) {
    if (state != mode) {
      emit(mode);
    }
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    return _stringToThemeMode(json['theme'] ?? '');
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme': state.name};
  }

  ThemeMode _stringToThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

}

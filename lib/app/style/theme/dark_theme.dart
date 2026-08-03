import 'package:flutter/material.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

import '../colors/player_colors.dart';

const _scheme = ColorScheme.dark(
  primary: AppColors.teal300,
  onPrimary: AppColors.night900,
  secondary: AppColors.gold300,
  onSecondary: AppColors.night900,
  surface: AppColors.night800,
  onSurface: AppColors.inkDark,
  error: AppColors.errorDark,
  onError: AppColors.night900,
  outline: AppColors.night600,
);
// ignore: non_constant_identifier_names
ThemeData DARK_THEME = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _scheme,
  scaffoldBackgroundColor: AppColors.night900,

  /// textTheme: _buildTextTheme(AppColors.inkDark, AppColors.inkDarkSecondary),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.night900,
    foregroundColor: AppColors.inkDark,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: AppColors.night700,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.night600, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.teal300,
    textColor: AppColors.inkDark,
    selectedTileColor: AppColors.night700,
    selectedColor: AppColors.gold300,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: AppColors.inkDark, fontSize: 15),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.night700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.night600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.night600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal300, width: 1.5),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.teal300),
  dividerTheme: const DividerThemeData(
    color: AppColors.night600,
    thickness: 1,
    space: 1,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.teal300,
    inactiveTrackColor: AppColors.night600,
    thumbColor: AppColors.teal300,
    overlayColor: AppColors.teal300.withValues(alpha: 0.2),
    trackHeight: 3,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.teal300,
    foregroundColor: AppColors.night900,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.teal300,
      foregroundColor: AppColors.night900,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  extensions: const [PlayerColors.dark],
);

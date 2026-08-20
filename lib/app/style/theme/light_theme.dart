import 'package:flutter/material.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

import '../colors/player_colors.dart';

const _scheme = ColorScheme.light(
  primary: AppColors.teal500,
  onPrimary: Colors.white,
  secondary: AppColors.gold500,
  onSecondary: Colors.white,
  surface: AppColors.sand50,
  onSurface: AppColors.inkLight,
  error: AppColors.error,
  onError: Colors.white,
  outline: AppColors.sand200,
);

// ignore: non_constant_identifier_names
ThemeData LIGHT_THEME = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: _scheme,
  scaffoldBackgroundColor: AppColors.sand50,

  /// textTheme: _buildTextTheme(AppColors.inkLight, AppColors.inkLightSecondary),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.sand50,
    foregroundColor: AppColors.inkLight,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: AppColors.sand100,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.sand200, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.teal500,
    textColor: AppColors.inkLight,
    selectedTileColor: AppColors.teal50,
    selectedColor: AppColors.teal600,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: AppColors.inkLight, fontSize: 15),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.sand100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sand200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sand200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal500, width: 1.5),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.teal500),
  dividerTheme: const DividerThemeData(
    color: AppColors.sand200,
    thickness: 1,
    space: 1,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.teal500,
    inactiveTrackColor: AppColors.sand200,
    thumbColor: AppColors.teal500,
    overlayColor: AppColors.teal100.withValues(alpha: 0.3),
    trackHeight: 3,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.teal500,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.teal500,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  extensions: const [PlayerColors.light],
);

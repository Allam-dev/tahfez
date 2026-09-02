import 'package:flutter/material.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

import '../colors/player_colors.dart';

const _scheme = ColorScheme.dark(
  primary: AppColors.green400,
  onPrimary: AppColors.night900,
  secondary: AppColors.green300,
  onSecondary: AppColors.night900,
  surface: AppColors.night800,
  onSurface: AppColors.inkDark,
  surfaceContainer: AppColors.night700,
  surfaceContainerHigh: AppColors.night600,
  error: AppColors.errorDark,
  onError: AppColors.night900,
  outline: AppColors.night600,
  outlineVariant: AppColors.night700,
);

// ignore: non_constant_identifier_names
ThemeData DARK_THEME = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _scheme,
  scaffoldBackgroundColor: AppColors.night900,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.night900,
    foregroundColor: AppColors.inkDark,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.inkDark),
  ),
  cardTheme: CardThemeData(
    color: AppColors.night800,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.night600, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.green300,
    textColor: AppColors.inkDark,
    selectedTileColor: AppColors.night700,
    selectedColor: AppColors.green300,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: AppColors.inkDark, fontSize: 15),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.night800,
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
        borderSide: const BorderSide(color: AppColors.green400, width: 1.5),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.green400),
  dividerTheme: const DividerThemeData(
    color: AppColors.night600,
    thickness: 1,
    space: 1,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.green400,
    inactiveTrackColor: AppColors.night600,
    thumbColor: AppColors.green400,
    overlayColor: AppColors.green400.withValues(alpha: 0.2),
    trackHeight: 4,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : AppColors.inkDarkSecondary,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.green500
          : AppColors.night700,
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.night900,
    disabledColor: AppColors.night800,
    selectedColor: AppColors.night700,
    secondarySelectedColor: AppColors.night700,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(color: AppColors.inkDark, fontSize: 13),
    secondaryLabelStyle: const TextStyle(
        color: AppColors.green300, fontWeight: FontWeight.w600, fontSize: 13),
    brightness: Brightness.dark,
    side: const BorderSide(color: AppColors.night600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.night900,
    elevation: 0,
    indicatorColor: AppColors.night700,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.green300)
          : const IconThemeData(color: AppColors.inkDarkSecondary),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const TextStyle(
              color: AppColors.green300,
              fontWeight: FontWeight.bold,
              fontSize: 12)
          : const TextStyle(color: AppColors.inkDarkSecondary, fontSize: 12),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.night900,
    elevation: 0,
    selectedItemColor: AppColors.green300,
    unselectedItemColor: AppColors.inkDarkSecondary,
    type: BottomNavigationBarType.fixed,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.green500,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.green500,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.green300,
      elevation: 0,
      side: const BorderSide(color: AppColors.night600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  extensions: const [PlayerColors.dark],
);


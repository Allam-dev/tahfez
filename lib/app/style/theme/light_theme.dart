import 'package:flutter/material.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

import '../colors/player_colors.dart';

const _scheme = ColorScheme.light(
  primary: AppColors.green500,
  onPrimary: Colors.white,
  secondary: AppColors.green600,
  onSecondary: Colors.white,
  surface: AppColors.sand50,
  onSurface: AppColors.inkLight,
  surfaceContainer: AppColors.sand100,
  surfaceContainerHigh: AppColors.sand150,
  error: AppColors.error,
  onError: Colors.white,
  outline: AppColors.sand200,
  outlineVariant: AppColors.sand100,
);

// ignore: non_constant_identifier_names
ThemeData LIGHT_THEME = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: _scheme,
  scaffoldBackgroundColor: AppColors.sand50,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.sand50,
    foregroundColor: AppColors.inkLight,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.inkLight),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.sand200, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.green500,
    textColor: AppColors.inkLight,
    selectedTileColor: AppColors.sand100,
    selectedColor: AppColors.green600,
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
        borderSide: const BorderSide(color: AppColors.green500, width: 1.5),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.green500),
  dividerTheme: const DividerThemeData(
    color: AppColors.sand200,
    thickness: 1,
    space: 1,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.green500,
    inactiveTrackColor: AppColors.sand200,
    thumbColor: AppColors.green500,
    overlayColor: AppColors.green100.withValues(alpha: 0.3),
    trackHeight: 4,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => Colors.white,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.green500
          : AppColors.sand200,
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.sand50,
    disabledColor: AppColors.sand100,
    selectedColor: AppColors.sand100,
    secondarySelectedColor: AppColors.sand100,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(color: AppColors.inkLight, fontSize: 13),
    secondaryLabelStyle: const TextStyle(
        color: AppColors.green500, fontWeight: FontWeight.w600, fontSize: 13),
    brightness: Brightness.light,
    side: const BorderSide(color: AppColors.sand200),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.sand50,
    elevation: 0,
    indicatorColor: AppColors.sand100,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.green500)
          : const IconThemeData(color: AppColors.inkLightSecondary),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const TextStyle(
              color: AppColors.green500,
              fontWeight: FontWeight.bold,
              fontSize: 12)
          : const TextStyle(color: AppColors.inkLightSecondary, fontSize: 12),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.sand50,
    elevation: 0,
    selectedItemColor: AppColors.green500,
    unselectedItemColor: AppColors.inkLightSecondary,
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
      foregroundColor: AppColors.green500,
      elevation: 0,
      side: const BorderSide(color: AppColors.sand200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  extensions: const [PlayerColors.light],
);


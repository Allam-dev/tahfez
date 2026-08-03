import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
 

  @override
  AppThemeExtension copyWith({
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return AppThemeExtension(
     
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
     
    );
  }
}
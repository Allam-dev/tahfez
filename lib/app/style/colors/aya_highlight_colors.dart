import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AyaHighlightColors extends ThemeExtension<AyaHighlightColors> {
  final Color fill;
  final Color glow;

  const AyaHighlightColors({
    required this.fill,
    required this.glow,
  });

  static final light = AyaHighlightColors(
    fill: AppColors.gold300.withValues(alpha: 0.25),
    glow: AppColors.gold300.withValues(alpha: 0.12),
  );

  static final dark = AyaHighlightColors(
    fill: AppColors.gold500.withValues(alpha: 0.25),
    glow: AppColors.gold500.withValues(alpha: 0.12),
  );

  @override
  AyaHighlightColors copyWith({
    Color? fill,
    Color? glow,
  }) {
    return AyaHighlightColors(
      fill: fill ?? this.fill,
      glow: glow ?? this.glow,
    );
  }

  @override
  AyaHighlightColors lerp(ThemeExtension<AyaHighlightColors>? other, double t) {
    if (other is! AyaHighlightColors) return this;
    return AyaHighlightColors(
      fill: Color.lerp(fill, other.fill, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class PlayerColors extends ThemeExtension<PlayerColors> {
  final Color progressTrack;
  final Color progressFill;
  final Color waveformIdle;
  final Color waveformActive;
  final Color nowPlayingBg;
  final Color nowPlayingBorder;

  const PlayerColors({
    required this.progressTrack,
    required this.progressFill,
    required this.waveformIdle,
    required this.waveformActive,
    required this.nowPlayingBg,
    required this.nowPlayingBorder,
  });

  static const light = PlayerColors(
    progressTrack: AppColors.sand200,
    progressFill: AppColors.green500,
    waveformIdle: AppColors.green100,
    waveformActive: AppColors.green500,
    nowPlayingBg: AppColors.sand100,
    nowPlayingBorder: AppColors.green100,
  );

  static const dark = PlayerColors(
    progressTrack: AppColors.night600,
    progressFill: AppColors.green400,
    waveformIdle: AppColors.night600,
    waveformActive: AppColors.green300,
    nowPlayingBg: AppColors.night800,
    nowPlayingBorder: AppColors.night600,
  );

  @override
  PlayerColors copyWith({
    Color? progressTrack,
    Color? progressFill,
    Color? waveformIdle,
    Color? waveformActive,
    Color? nowPlayingBg,
    Color? nowPlayingBorder,
  }) {
    return PlayerColors(
      progressTrack: progressTrack ?? this.progressTrack,
      progressFill: progressFill ?? this.progressFill,
      waveformIdle: waveformIdle ?? this.waveformIdle,
      waveformActive: waveformActive ?? this.waveformActive,
      nowPlayingBg: nowPlayingBg ?? this.nowPlayingBg,
      nowPlayingBorder: nowPlayingBorder ?? this.nowPlayingBorder,
    );
  }

  @override
  PlayerColors lerp(ThemeExtension<PlayerColors>? other, double t) {
    if (other is! PlayerColors) return this;
    return PlayerColors(
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      progressFill: Color.lerp(progressFill, other.progressFill, t)!,
      waveformIdle: Color.lerp(waveformIdle, other.waveformIdle, t)!,
      waveformActive: Color.lerp(waveformActive, other.waveformActive, t)!,
      nowPlayingBg: Color.lerp(nowPlayingBg, other.nowPlayingBg, t)!,
      nowPlayingBorder:
          Color.lerp(nowPlayingBorder, other.nowPlayingBorder, t)!,
    );
  }
}
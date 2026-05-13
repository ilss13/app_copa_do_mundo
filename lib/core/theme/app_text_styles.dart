import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: 'Roboto',
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  // Display
  static final displayLarge = _base.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static final displayMedium = _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700);

  // Headlines
  static final headlineLarge = _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700);
  static final headlineMedium = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static final headlineSmall = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  // Body
  static final bodyLarge = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400);
  static final bodyMedium = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static final bodySmall = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // Labels
  static final labelLarge = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static final labelMedium = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static final labelSmall = _base.copyWith(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.0);

  // Score / Placar
  static final score = _base.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static final scoreLive = _base.copyWith(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: -0.5);
}

import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';

import 'app_colors.dart';

/// The single dark "hacker" theme used across the whole app.
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        onPrimary: Color(0xFF03231A),
        secondary: AppColors.neonCyan,
        onSecondary: Color(0xFF002733),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.cardBorder,
        surfaceTint: Colors.transparent, // no purple M3 tint anywhere
      ),
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
    );

    return base.copyWith(
      textTheme: AppFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dividerColor: AppColors.cardBorder,
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.neonGreen.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.neonGreen
                : AppColors.textDim,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.neonGreen
                : AppColors.textDim,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.neonGreen,
        inactiveTrackColor: AppColors.cardBorder,
        thumbColor: AppColors.neonGreen,
        overlayColor: AppColors.neonGreen.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.card,
        valueIndicatorTextStyle: AppFonts.jetBrainsMono(
          color: AppColors.neonGreen,
          fontSize: 13,
        ),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

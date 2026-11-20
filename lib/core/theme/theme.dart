import 'package:flutter/material.dart';

/// MyMeds palette.
class AppColors {
  AppColors._();
  static const Color navy = Color(0xFF1F3892);
  static const Color blue = Color(0xFF0056FF);
  static const Color sky = Color(0xFF5DB4FF);
  static const Color cyan = Color(0xFF00DEE3);

  // Dark mode background (near-black)
  static const Color ink = Color(0xFF0B0F1A);
}

/// MyMeds application theme, Material 3.
class AppTheme {
  AppTheme._();

  static Color _tint(Color base, Color tint, double amount) =>
      Color.alphaBlend(tint.withValues(alpha: amount), base);

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData get light {
    const white = Colors.white;
    final colorScheme = ColorScheme.light(
      primary: AppColors.blue,
      onPrimary: white,
      primaryContainer: _tint(white, AppColors.sky, 0.35),
      onPrimaryContainer: AppColors.navy,
      secondary: AppColors.cyan,
      onSecondary: AppColors.navy,
      secondaryContainer: _tint(white, AppColors.cyan, 0.25),
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.sky,
      onTertiary: AppColors.navy,
      surface: white,
      onSurface: AppColors.navy,
      surfaceContainerLow: _tint(white, AppColors.sky, 0.10),
      surfaceContainerHighest: _tint(white, AppColors.sky, 0.18),
      onSurfaceVariant: AppColors.navy,
      outline: AppColors.sky,
    );
    return _buildTheme(colorScheme);
  }

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData get dark {
    const white = Colors.white;
    final colorScheme = ColorScheme.dark(
      primary: AppColors.sky,
      onPrimary: AppColors.ink,
      primaryContainer: _tint(AppColors.ink, AppColors.blue, 0.35),
      onPrimaryContainer: white,
      secondary: AppColors.cyan,
      onSecondary: AppColors.ink,
      secondaryContainer: _tint(AppColors.ink, AppColors.cyan, 0.25),
      onSecondaryContainer: white,
      tertiary: AppColors.sky,
      onTertiary: AppColors.ink,
      surface: AppColors.ink,
      onSurface: white,
      surfaceContainerLow: _tint(AppColors.ink, AppColors.navy, 0.30),
      surfaceContainerHighest: _tint(AppColors.ink, AppColors.navy, 0.45),
      onSurfaceVariant: Colors.white70,
      outline: AppColors.sky,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isLight ? AppColors.blue : colorScheme.surface,
        foregroundColor: isLight ? Colors.white : colorScheme.onSurface,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppColors.cyan,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.cyan,
        foregroundColor: isLight ? AppColors.navy : AppColors.ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
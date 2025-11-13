import 'package:flutter/material.dart';

class ThemeConfig {
  // Primary colors
  static const Color primaryColor = Color(0xFF1C592B); // dark green
  static const Color primaryLightColor = Color(0xFF81C784);
  static const Color primaryDarkColor = Color(0xFF388E3C);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryLightColor = Color(0xFFFFB74D);
  static const Color secondaryDarkColor = Color(0xFFF57C00);

  // Accent colors
  static const Color accentColor = Color(0xFF2196F3); // Blue

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Error and success colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  // AppBar theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor:  Color(0xFF1C592B), // dark green
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  );

  // Get the theme data
  static ThemeData getThemeData({bool isDarkMode = false}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1C592B),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: const Color(0xFF1C592B),
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundColor,
      ),
      useMaterial3: true,
      fontFamily: 'Poppins',
      appBarTheme: appBarTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C592B),
          foregroundColor: const Color(0xFFF2F2F2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        displayMedium: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        displaySmall: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        headlineLarge: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        headlineMedium: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        headlineSmall: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        titleLarge: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        titleMedium: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        titleSmall: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        bodyLarge: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        bodyMedium: const TextStyle(
          color: textPrimaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
        bodySmall: const TextStyle(
          color: textSecondaryColor,
          fontFamily: 'Poppins',
        ).apply(fontFamilyFallback: ['sans-serif']),
      ),
    );
  }
}

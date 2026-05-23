import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData theme(bool isDarkMode, double fontSizeFactor) {
    return isDarkMode ? darkTheme(fontSizeFactor) : lightTheme(fontSizeFactor);
  }

  static ThemeData lightTheme(double fontSizeFactor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.mediumGrey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      textTheme: _textTheme(AppColors.textPrimary, fontSizeFactor),
    );
  }

  static ThemeData darkTheme(double fontSizeFactor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
      textTheme: _textTheme(Colors.white, fontSizeFactor),
    );
  }

  static TextTheme _textTheme(Color color, double factor) {
    return TextTheme(
      displayLarge: TextStyle(color: color, fontSize: 32 * factor),
      displayMedium: TextStyle(color: color, fontSize: 28 * factor),
      displaySmall: TextStyle(color: color, fontSize: 24 * factor),
      headlineMedium: TextStyle(color: color, fontSize: 20 * factor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: color, fontSize: 18 * factor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: color, fontSize: 16 * factor),
      bodyMedium: TextStyle(color: color, fontSize: 14 * factor),
      bodySmall: TextStyle(color: color, fontSize: 12 * factor),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primary),
        background: const Color(AppColors.background),
        surface: const Color(AppColors.surface),
      ),
      scaffoldBackgroundColor: const Color(AppColors.background),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.background),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(AppColors.textPrimary)),
        titleTextStyle: TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        color: const Color(AppColors.surface),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(AppColors.primary),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkCameraTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Color(AppColors.primary),
        surface: Color(0xFF1E1E1E),
      ),
    );
  }
}

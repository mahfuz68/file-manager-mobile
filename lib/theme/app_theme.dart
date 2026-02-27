// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette — mirrors the web app's CSS variables
  static const background = Color(0xFF0A0A0A);
  static const card = Color(0xFF161616);
  static const surface = Color(0xFF0F0F0F);
  static const surfaceHover = Color(0xFF1F1F1F);
  static const border = Color(0xFF2A2A2A);
  static const input = Color(0xFF1A1A1A);

  // Primary orange
  static const primary = Color(0xFFF97316);
  static const primaryHover = Color(0xFFEA6C0A);
  static const primarySubtle = Color(0x1AF97316);

  // Success green
  static const success = Color(0xFF22C55E);
  static const successSubtle = Color(0x0F22C55E);

  // Destructive red
  static const destructive = Color(0xFFEF4444);
  static const destructiveSubtle = Color(0x0DEF4444);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF71717A);
  static const textDimmed = Color(0xFF444444);

  // File type colours
  static const video = Color(0xFFF97316);
  static const image = Color(0xFF3B82F6);
  static const document = Color(0xFF22C55E);
  static const audio = Color(0xFFA855F7);
  static const archive = Color(0xFFEAB308);
  static const code = Color(0xFF8B5CF6);
  static const fileGeneric = Color(0xFF71717A);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        background: AppColors.background,
        surface: AppColors.card,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        error: AppColors.destructive,
        outline: AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodySmall: GoogleFonts.jetBrainsMono(color: AppColors.textMuted),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: AppColors.textMuted,
          letterSpacing: 1.5,
        ),
      ),
      dividerColor: AppColors.border,
      cardColor: AppColors.card,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF242424)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF242424)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF3A3A3A)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogBackgroundColor: AppColors.surface,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

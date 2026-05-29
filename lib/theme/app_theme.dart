import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === WARNA UTAMA ===
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color accentGold = Color(0xFFD4A017);

  // === LIGHT MODE ===
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFE53935);

  // === LIGHT THEME ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGold,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7F5),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFEEEEEE),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGreen;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen.withValues(alpha: 0.4);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // === DARK THEME ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreenLight,
        secondary: accentGold,
        surface: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF2C2C2C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreenLight, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF666666)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGreenLight;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreenLight.withValues(alpha: 0.4);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }
}

// ✅ Extension helper — gunakan di semua screen
// Contoh: context.bgColor, context.cardColor, dll
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Background utama halaman
  Color get bgColor =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F5);

  // Warna card / container putih
  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  // Warna card sedikit lebih terang (untuk nested card)
  Color get cardColorElevated =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  // Border card
  Color get borderColor =>
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);

  // Teks utama
  Color get textPrimary => isDark ? Colors.white : AppTheme.textDark;

  // Teks sekunder / label
  Color get textSecondary => isDark ? Colors.grey.shade400 : AppTheme.textGrey;

  // Teks hint / placeholder
  Color get textHint => isDark ? Colors.grey.shade600 : AppTheme.textLight;

  // Background icon bulat hijau
  Color get iconBgColor =>
      isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9);

  // Background input field
  Color get inputFillColor =>
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F9F9);

  // Warna divider / garis pemisah
  Color get dividerColor =>
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);

  // Warna border input
  Color get inputBorderColor =>
      isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0);

  // Background search bar
  Color get searchBgColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  // Warna status badge background
  Color get badgeBgMenunggu =>
      isDark ? const Color(0xFF3E2800) : const Color(0xFFFFF3E0);

  Color get badgeBgProses =>
      isDark ? const Color(0xFF0D2137) : const Color(0xFFE3F2FD);

  Color get badgeBgSelesai =>
      isDark ? const Color(0xFF0D2E12) : const Color(0xFFE8F5E9);

  // Warna highlight/aksen ringan
  Color get highlightColor => isDark
      ? AppTheme.primaryGreen.withValues(alpha: 0.2)
      : AppTheme.primaryGreen.withValues(alpha: 0.1);
}

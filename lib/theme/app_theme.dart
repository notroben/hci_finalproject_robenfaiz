import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Color Constants (WCAG AA Compliant)
  static const Color boneLight = Color(0xFFFDFBF7);
  static const Color sageGreen = Color(0xFF3A6351);
  static const Color ochreGold = Color(0xFFE3B04B);
  static const Color deepForest = Color(0xFF1E3A2F);
  static const Color darkBg = Color(0xFF121212);
  static const Color charcoalText = Color(0xFF2C2C2C);
  static const Color creamText = Color(0xFFEBE3D5);

  // High Contrast Mode Colors
  static const Color hcBg = Colors.black;
  static const Color hcText = Colors.white;
  static const Color hcBorder = Colors.white;

  /// Helper to get the base TextStyle with accessibility spacings
  static TextStyle _baseStyle(TextStyle style) {
    return style.copyWith(
      height: 1.5, // WCAG line-height standard
      letterSpacing: 0.15, // Dyslexia reading space standard
    );
  }

  /// Get TextTheme dynamically based on the selected font name
  static TextTheme getTextTheme(String fontName, Color textColor) {
    TextTheme baseTheme;
    if (fontName == 'OpenDyslexic') {
      // Set OpenDyslexic as font family. Fallback to dynamic Sans-Serif if asset not loaded
      baseTheme = const TextTheme(
        displayLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        displayMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        displaySmall: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineSmall: TextStyle(fontFamily: 'OpenDyslexic'),
        titleLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        titleMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        titleSmall: TextStyle(fontFamily: 'OpenDyslexic'),
        bodyLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        bodyMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        bodySmall: TextStyle(fontFamily: 'OpenDyslexic'),
        labelLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        labelMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        labelSmall: TextStyle(fontFamily: 'OpenDyslexic'),
      );
    } else if (fontName == 'Atkinson Hyperlegible') {
      baseTheme = GoogleFonts.atkinsonHyperlegibleTextTheme();
    } else {
      baseTheme = GoogleFonts.robotoTextTheme();
    }

    return TextTheme(
      headlineLarge: _baseStyle(
        baseTheme.headlineLarge ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: _baseStyle(
        baseTheme.headlineMedium ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
      headlineSmall: _baseStyle(
        baseTheme.headlineSmall ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: _baseStyle(
        baseTheme.titleLarge ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 22),
      titleMedium: _baseStyle(
        baseTheme.titleMedium ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
      titleSmall: _baseStyle(
        baseTheme.titleSmall ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: _baseStyle(
        baseTheme.bodyLarge ?? const TextStyle(),
      ).copyWith(color: textColor, fontSize: 18),
      bodyMedium: _baseStyle(
        baseTheme.bodyMedium ?? const TextStyle(),
      ).copyWith(color: textColor, fontSize: 16),
      bodySmall: _baseStyle(
        baseTheme.bodySmall ?? const TextStyle(),
      ).copyWith(color: textColor, fontSize: 14),
      labelLarge: _baseStyle(
        baseTheme.labelLarge ?? const TextStyle(),
      ).copyWith(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  static ThemeData buildTheme({
    required String fontName,
    required bool isDark,
    required bool isHighContrast,
  }) {
    if (isHighContrast) {
      final textTheme = getTextTheme(fontName, hcText);
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: hcBg,
        primaryColor: hcText,
        cardColor: hcBg,
        dividerColor: hcBorder,
        fontFamily: fontName == 'OpenDyslexic' ? 'OpenDyslexic' : null,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: hcBg,
          elevation: 0,
          titleTextStyle: textTheme.titleLarge,
          iconTheme: const IconThemeData(color: hcText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: hcBg,
            foregroundColor: hcText,
            side: const BorderSide(color: hcBorder, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: hcText,
            side: const BorderSide(color: hcBorder, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: hcBg,
          filled: true,
          labelStyle: textTheme.bodyMedium,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: hcBorder, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: hcBorder, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }

    final Color bgColor = isDark ? darkBg : boneLight;
    final Color textColor = isDark ? creamText : charcoalText;
    final textTheme = getTextTheme(fontName, textColor);

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      primaryColor: sageGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sageGreen,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: sageGreen,
        secondary: ochreGold,
        background: bgColor,
      ),
      cardColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0EAE1),
      dividerColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFD4C5B9),
      fontFamily: fontName == 'OpenDyslexic' ? 'OpenDyslexic' : null,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: sageGreen,
          side: const BorderSide(color: sageGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: sageGreen),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
        labelStyle: textTheme.bodyMedium,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFD4C5B9),
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: sageGreen, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}

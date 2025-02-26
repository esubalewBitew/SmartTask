import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[100],
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.grey[800]),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.grey[800],
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(color: Colors.black),
      displayMedium: GoogleFonts.poppins(color: Colors.black),
      displaySmall: GoogleFonts.poppins(color: Colors.black),
      headlineLarge: GoogleFonts.poppins(color: Colors.black),
      headlineMedium: GoogleFonts.poppins(color: Colors.black),
      headlineSmall: GoogleFonts.poppins(color: Colors.black),
      titleLarge: GoogleFonts.poppins(color: Colors.black),
      titleMedium: GoogleFonts.poppins(color: Colors.black),
      titleSmall: GoogleFonts.poppins(color: Colors.black),
      bodyLarge: GoogleFonts.poppins(color: Colors.black),
      bodyMedium: GoogleFonts.poppins(color: Colors.black),
      bodySmall: GoogleFonts.poppins(color: Colors.black),
    ),
    dividerColor: Colors.grey[300],
    iconTheme: IconThemeData(color: Colors.grey[800]),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    cardColor: const Color(0xFF2C2C2E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2C2C2E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(color: Colors.white),
      displayMedium: GoogleFonts.poppins(color: Colors.white),
      displaySmall: GoogleFonts.poppins(color: Colors.white),
      headlineLarge: GoogleFonts.poppins(color: Colors.white),
      headlineMedium: GoogleFonts.poppins(color: Colors.white),
      headlineSmall: GoogleFonts.poppins(color: Colors.white),
      titleLarge: GoogleFonts.poppins(color: Colors.white),
      titleMedium: GoogleFonts.poppins(color: Colors.white),
      titleSmall: GoogleFonts.poppins(color: Colors.white),
      bodyLarge: GoogleFonts.poppins(color: Colors.white),
      bodyMedium: GoogleFonts.poppins(color: Colors.white),
      bodySmall: GoogleFonts.poppins(color: Colors.white),
    ),
    dividerColor: Colors.grey[800],
    iconTheme: const IconThemeData(color: Colors.white),
  );

  // Helper methods for getting theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
}

import 'package:smarttask/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SaveCaches {
  SaveCaches._();
  late Box box;

  // for singleton
  static final SaveCaches _instance = SaveCaches._();

  // fpor accesing singleting instances
  static SaveCaches get instance => _instance;

// initilising open box
  Future<void> initialize() async {
    box = await Hive.openBox(CustomHiveBoxKey.myBox);
  }

// Saving  Saving theme mode box

  Future<void> saveThemeMode(String theme) async {
    await box.put('theme', theme);
  }

// Saving  getting theme mode box

  Future<String> getThemeMode() async {
    var theme = box.get('theme') ?? '';
    return theme as String;
  }

//checking if the user visits the app for the first time

  Future<void> cacheFirstTimer() async {
    try {
      box.put(CustomHiveBoxKey.kFirstTimerKey, false);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

//Seeting when the user visits the app for the first time
  @override
  Future<bool> checkIfUserIsFirstTimer() async {
    try {
      box = await Hive.box('myBox');

      var value = box.get(
            CustomHiveBoxKey.kFirstTimerKey,
          ) ??
          true;

      return value as bool;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}

class CustomHiveBoxKey {
  static const String myBox = 'mybox';
  static const kFirstTimerKey = 'first_timer';

  CustomHiveBoxKey._();
}

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class CoreTheme {
  ThemeData get themeData;

  Color get primaryColor;
  Color get secondaryColor;
  Color get backgroundColor;
  Color get secondaryBackgroundColor;
  Color get errorColor;
  Color get warningColor;
  Color get helpColor;
  Color get tFieldPrimary;

  static Future<SharedPreferences> initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  // static void saveThemeMode(ThemeMode mode) {
  //   _prefs?.setString(kThemeModeKey, mode.toString().split('.').last);
  // }

  static ThemeMode get themeMode {
    return ThemeMode.light;
  }

  static ThemeData getThemeData(BuildContext context,
      {bool isBirrTheme = false}) {
    return isBirrTheme
        ? LightModeTheme().birrThemeData
        : LightModeTheme().themeData;
  }
}

class LightModeTheme extends CoreTheme {
  LinearGradient get primaryGradient => const LinearGradient(
        colors: [
          Color(0xFF0553A5), // Top color
          Color(0xFF0553A5), // Bottom color
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  @override
  Color get primaryColor => const Color(0xFF0553A5);
  Color get primaryColorBirr => const Color(0xFF0553A5);
  @override
  Color get secondaryColor => const Color(0xFFFFFFFF);
  @override
  Color get backgroundColor => const Color(0xFFFFFFFF);
  @override
  Color get secondaryBackgroundColor => const Color.fromRGBO(0, 0, 0, 1);

  @override
  Color get errorColor => const Color.fromRGBO(216, 0, 50, 1);
  @override
  Color get tFieldPrimary => const Color.fromRGBO(245, 245, 245, 1);

  @override
  Color get helpColor => const Color(0xff3282B8);
  @override
  Color get warningColor => const Color(0xffFCA652);

  Color get cardGradientStart => primaryColor.withOpacity(0.05);
  Color get cardGradientEnd => primaryColor.withOpacity(0.02);
  Color get cardBorder => primaryColor.withOpacity(0.1);

  @override
  ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        textTheme: GoogleFonts.outfitTextTheme(
          TextTheme(
            // Display styles
            displayLarge: TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),
            displayMedium: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),
            displaySmall: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),

            // Headline styles
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: secondaryBackgroundColor,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: secondaryBackgroundColor,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: secondaryBackgroundColor,
            ),

            // Title styles
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),
            titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),

            // Body styles
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: secondaryBackgroundColor,
            ),

            // Label styles
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),
            labelSmall: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: secondaryBackgroundColor,
            ),
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: backgroundColor,
          onSurface: secondaryBackgroundColor,
          primaryContainer: helpColor,
          secondaryContainer: warningColor,
          onTertiary: tFieldPrimary,
        ).copyWith(
          error: errorColor,
          tertiaryContainer: tFieldPrimary,
        ),
      );

  ThemeData get birrThemeData => ThemeData(
        primaryColor: primaryColorBirr,
        textTheme: GoogleFonts.outfitTextTheme(
            // ... same text theme as regular themeData ...
            ),
        colorScheme: ColorScheme.light(
          primary: primaryColorBirr,
          secondary: secondaryColor,
          surface: backgroundColor,
          onSurface: secondaryBackgroundColor,
          primaryContainer: helpColor,
          secondaryContainer: warningColor,
          onTertiary: tFieldPrimary,
        ).copyWith(
          error: errorColor,
          tertiaryContainer: tFieldPrimary,
        ),
      );
}

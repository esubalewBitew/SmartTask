import 'package:smarttask/core/res/cbrs_theme.dart';
import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => CoreTheme.getThemeData(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;

  LinearGradient get primaryGradient =>
      theme.primaryColor == const Color(0xFF2480A9)
          ? birrGradient
          : LightModeTheme().primaryGradient;

  LinearGradient get birrGradient => const LinearGradient(
        colors: [
          Color(0xFF5BA9C2), // Top color
          Color(0xFF2480A9), // Bottom color
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get redGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF5252),
          Color(0xFFFF1744),
        ],
      );
}

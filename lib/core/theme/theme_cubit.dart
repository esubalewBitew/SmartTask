import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum ThemeState { light, dark }

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(ThemeState.light) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  void _loadTheme() {
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(isDark ? ThemeState.dark : ThemeState.light);
  }

  void toggleTheme() {
    final newState =
        state == ThemeState.light ? ThemeState.dark : ThemeState.light;
    prefs.setBool(_themeKey, newState == ThemeState.dark);
    emit(newState);
  }
}

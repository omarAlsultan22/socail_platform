import 'package:flutter/material.dart';
import '../data/data_sources/local/cache_helper.dart';


class ThemeNotifier with ChangeNotifier {
  final CacheHelper _cacheHelper;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier({required CacheHelper cacheHelper})
      : _cacheHelper = cacheHelper {
    _loadTheme();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    await _cacheHelper.setString(key: 'theme', value: mode.toString());
  }

  void _loadTheme() async {
    try {
      String? theme = await _cacheHelper.getString(key: 'theme');
      if (theme == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else if (theme == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      print("Error loading theme: $e");
    }
  }
}








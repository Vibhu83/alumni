import 'package:alumni/ThemeData/theme_preference.dart';
import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  late bool _isDark;
  late ThemePreference _preference;
  bool get isDark => _isDark;

  ThemeModel() {
    _preference = ThemePreference();
    _isDark = false;
    getPreferences();
  }

  set isDark(bool value) {
    _isDark = value;
    _preference.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preference.getTheme();
    if (_isDark) {
      notifyListeners();
    }
  }
}

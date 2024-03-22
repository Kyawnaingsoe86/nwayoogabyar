import 'package:flutter/material.dart';
import 'package:nwayoogabyar/controller/sprf.dart';
import 'package:nwayoogabyar/data/credential.dart';
import 'package:nwayoogabyar/theme/color_schemes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData =
      UserCredential.themeMode == 'lightMode' ? lightMode : darkMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void setTheme() {
    themeData = UserCredential.themeMode == 'lightMode' ? lightMode : darkMode;
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
      Sprf().setThemeMode('darkMode');
    } else {
      themeData = lightMode;
      Sprf().setThemeMode('lightMode');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with ChangeNotifier {
  bool _darkMode;
  bool get darkMode => _darkMode;

  Preferences(this._darkMode);

  void setDarkMode(bool value) async {
    _darkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);

    notifyListeners();
  }
}

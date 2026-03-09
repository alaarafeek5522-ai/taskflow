import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isPinEnabled = false;
  String _pin = '';

  bool get isDarkMode => _isDarkMode;
  bool get isPinEnabled => _isPinEnabled;
  String get pin => _pin;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _isPinEnabled = prefs.getBool('pinEnabled') ?? false;
    _pin = prefs.getString('pin') ?? '';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _pin = pin;
    _isPinEnabled = pin.isNotEmpty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin', pin);
    await prefs.setBool('pinEnabled', _isPinEnabled);
    notifyListeners();
  }
}

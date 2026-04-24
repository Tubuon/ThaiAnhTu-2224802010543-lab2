import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final _storage = StorageService();

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() { _loadTheme(); }

  Future<void> _loadTheme() async {
    final mode = await _storage.loadThemeMode();
    _themeMode = mode == 'light' ? ThemeMode.light
        : mode == 'dark' ? ThemeMode.dark : ThemeMode.system;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final name = mode == ThemeMode.light ? 'light'
        : mode == ThemeMode.dark ? 'dark' : 'system';
    await _storage.saveThemeMode(name);
  }
}
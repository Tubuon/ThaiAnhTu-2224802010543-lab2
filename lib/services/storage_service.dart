import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';

class StorageService {
  static const _historyKey = 'calculation_history';
  static const _themeKey = 'theme_mode';
  static const _modeKey = 'calculator_mode';
  static const _angleModeKey = 'angle_mode';
  static const _memoryKey = 'memory_value';
  static const _precisionKey = 'decimal_precision';
  static const _historySizeKey = 'history_size';

  Future<void> saveHistory(List<CalculationHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _historyKey, history.map((h) => jsonEncode(h.toJson())).toList());
  }

  Future<List<CalculationHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_historyKey) ?? [])
        .map((s) => CalculationHistory.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> saveThemeMode(String mode) async =>
      (await SharedPreferences.getInstance()).setString(_themeKey, mode);
  Future<String> loadThemeMode() async =>
      (await SharedPreferences.getInstance()).getString(_themeKey) ?? 'system';

  Future<void> saveCalculatorMode(String mode) async =>
      (await SharedPreferences.getInstance()).setString(_modeKey, mode);
  Future<String> loadCalculatorMode() async =>
      (await SharedPreferences.getInstance()).getString(_modeKey) ?? 'basic';

  Future<void> saveAngleMode(String mode) async =>
      (await SharedPreferences.getInstance()).setString(_angleModeKey, mode);
  Future<String> loadAngleMode() async =>
      (await SharedPreferences.getInstance()).getString(_angleModeKey) ?? 'degrees';

  Future<void> saveMemoryValue(double value) async =>
      (await SharedPreferences.getInstance()).setDouble(_memoryKey, value);
  Future<double> loadMemoryValue() async =>
      (await SharedPreferences.getInstance()).getDouble(_memoryKey) ?? 0.0;

  Future<void> saveDecimalPrecision(int p) async =>
      (await SharedPreferences.getInstance()).setInt(_precisionKey, p);
  Future<int> loadDecimalPrecision() async =>
      (await SharedPreferences.getInstance()).getInt(_precisionKey) ?? 6;

  Future<void> saveHistorySize(int size) async =>
      (await SharedPreferences.getInstance()).setInt(_historySizeKey, size);
  Future<int> loadHistorySize() async =>
      (await SharedPreferences.getInstance()).getInt(_historySizeKey) ?? 50;

  Future<void> clearHistory() async =>
      (await SharedPreferences.getInstance()).remove(_historyKey);
}
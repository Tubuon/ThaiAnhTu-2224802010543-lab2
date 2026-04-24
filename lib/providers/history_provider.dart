import 'package:flutter/foundation.dart';
import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<CalculationHistory> _history = [];
  int _historySize = 50;
  final _storage = StorageService();

  List<CalculationHistory> get history => List.unmodifiable(_history);
  int get historySize => _historySize;

  HistoryProvider() { _load(); }

  Future<void> _load() async {
    _history = await _storage.loadHistory();
    _historySize = await _storage.loadHistorySize();
    notifyListeners();
  }

  Future<void> add(String expression, String result) async {
    _history.insert(0, CalculationHistory(
        expression: expression, result: result, timestamp: DateTime.now()));
    if (_history.length > _historySize)
      _history = _history.sublist(0, _historySize);
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clear() async {
    _history = [];
    notifyListeners();
    await _storage.clearHistory();
  }

  Future<void> setHistorySize(int size) async {
    _historySize = size;
    if (_history.length > size) _history = _history.sublist(0, size);
    notifyListeners();
    await _storage.saveHistorySize(size);
  }
}

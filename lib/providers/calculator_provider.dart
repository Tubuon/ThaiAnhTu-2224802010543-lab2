import 'package:flutter/foundation.dart';
import '../models/calculator_mode.dart';
import '../utils/expression_parser.dart';
import '../utils/calculator_logic.dart';
import '../services/storage_service.dart';
import 'package:flutter/services.dart';

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _display = '0';
  String _previousResult = '';
  double _memory = 0;
  bool _hasError = false;
  bool _justEvaluated = false;
  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  int _decimalPrecision = 6;
  bool _isSecond = false;
  bool _hapticFeedback = true;
  bool get hapticFeedback => _hapticFeedback;


  final _storage = StorageService();

  String get expression => _expression;
  String get display => _display;
  String get previousResult => _previousResult;
  double get memory => _memory;
  bool get hasError => _hasError;
  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  int get decimalPrecision => _decimalPrecision;
  bool get hasMemory => _memory != 0;
  bool get isSecond => _isSecond;

  CalculatorProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final modeStr = await _storage.loadCalculatorMode();
    final angleStr = await _storage.loadAngleMode();
    _memory = await _storage.loadMemoryValue();
    _decimalPrecision = await _storage.loadDecimalPrecision();
    _mode = modeStr == 'scientific'
        ? CalculatorMode.scientific
        : modeStr == 'programmer'
        ? CalculatorMode.programmer
        : CalculatorMode.basic;
    _angleMode = angleStr == 'radians' ? AngleMode.radians : AngleMode.degrees;
    notifyListeners();
  }

  void setMode(CalculatorMode mode) {
    _mode = mode;
    notifyListeners();
    _storage.saveCalculatorMode(mode.name);
  }

  void executeBitwise(String operator) {
    if (_hapticFeedback) HapticFeedback.lightImpact();

    try {
      int currentVal = int.parse(_display);
      int result;

      switch (operator) {
        case 'NOT':
          result = ~currentVal; // Bitwise NOT
          break;
        case '<<':
          result = currentVal << 1; // Shift Left 1 bit
          break;
        case '>>':
          result = currentVal >> 1; // Shift Right 1 bit
          break;
        default:
          return;
      }
      _display = result.toString();
      _expression =
      operator == 'NOT' ? 'NOT($currentVal)' : '$currentVal $operator 1';
      notifyListeners();
    } catch (e) {
      _display = 'Error';
      notifyListeners();
    }
  }
  void setHapticFeedback(bool value) {
    _hapticFeedback = value;
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    _angleMode = mode;
    notifyListeners();
    _storage.saveAngleMode(mode.name);
  }

  void setDecimalPrecision(int p) {
    _decimalPrecision = p;
    notifyListeners();
    _storage.saveDecimalPrecision(p);
  }

  void toggleSecond() {
    _isSecond = !_isSecond;
    notifyListeners();
  }

  void input(String value) {
    _hasError = false;
    if (_justEvaluated && RegExp(r'[\d\.]').hasMatch(value)) {
      _expression = '';
      _display = '0';
      _previousResult = '';
    }
    _justEvaluated = false;

    if (value == '.') {
      final parts = _expression.split(RegExp(r'[\+\-\×\÷\(\)]'));
      final lastPart = parts.last;
      if (lastPart.contains('.')) return;
      if (lastPart.isEmpty) {
        _expression += '0';
        _display = '0.';
      } else {
        _expression += '.';
        _display += '.';
      }
    } else {
      if (_display == '0' && RegExp(r'\d').hasMatch(value)) {
        final ops = ['+', '-', '×', '÷'];
        final lastChar =
        _expression.isEmpty ? '' : _expression[_expression.length - 1];
        if (!ops.contains(lastChar)) {
          _expression = value;
          _display = value;
        } else {
          _expression += value;
          _display = value;
        }
      } else {
        _expression += value;
        _display += value;
      }
    }
    notifyListeners();
  }

  void inputOperator(String op) {
    _hasError = false;
    _justEvaluated = false;
    if (_expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      if (['+', '-', '×', '÷'].contains(lastChar)) {
        _expression =
            _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
      _display = op;
    }
    notifyListeners();
  }

  void inputFunction(String fn) {
    _hasError = false;
    _justEvaluated = false;
    _expression += '$fn(';
    _display = '$fn(';
    notifyListeners();
  }

  void openParen() {
    _expression += '(';
    _display = '(';
    notifyListeners();
  }

  void closeParen() {
    _expression += ')';
    _display = ')';
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.isNotEmpty) {
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
      _display = _expression;
      notifyListeners();
    }
  }

  void percent() {
    if (_expression.isNotEmpty) {
      try {
        final val = double.parse(_expression);
        _expression = (val / 100).toString();
        _display = _expression;
        notifyListeners();
      } catch (_) {}
    }
  }

  void inputConstant(String c) {
    _expression += c;
    _display = c;
    _justEvaluated = false;
    notifyListeners();
  }

  void backspace() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _display = _expression.isEmpty ? '0' : _expression[_expression.length - 1];
      notifyListeners();
    }
  }

  void clear() {
    _expression = '';
    _display = '0';
    _previousResult = '';
    _hasError = false;
    _justEvaluated = false;
    notifyListeners();
  }

  void clearEntry() {
    _display = '0';
    final match = RegExp(r'[\d\.]+$').firstMatch(_expression);
    if (match != null) {
      _expression = _expression.substring(0, match.start);
    }
    notifyListeners();
  }

  String? evaluate() {
    if (_expression.isEmpty) return null;
    final parser = ExpressionParser(angleMode: _angleMode);
    final result = parser.evaluate(_expression);
    if (result == 'Error') {
      _hasError = true;
      _display = 'Error';
      notifyListeners();
      return null;
    }
    _previousResult = _expression;
    _display = result;
    _expression = result;
    _justEvaluated = true;
    notifyListeners();
    return result;
  }

  void memoryAdd() {
    try {
      final val = double.parse(_display);
      _memory += val;
      _storage.saveMemoryValue(_memory);
      notifyListeners();
    } catch (_) {}
  }

  void memorySubtract() {
    try {
      final val = double.parse(_display);
      _memory -= val;
      _storage.saveMemoryValue(_memory);
      notifyListeners();
    } catch (_) {}
  }

  void memoryRecall() {
    final val = CalculatorLogic.formatResult(_memory, _decimalPrecision);
    _expression = val;
    _display = val;
    _justEvaluated = false;
    notifyListeners();
  }

  void memoryClear() {
    _memory = 0;
    _storage.saveMemoryValue(0);
    notifyListeners();
  }

  void square() {
    if (_expression.isNotEmpty) {
      _expression = '($_expression)^2';
      final result = evaluate();
      if (result != null) _expression = result;
    }
  }

  void squareRoot() {
    _expression = 'sqrt($_expression)';
    final result = evaluate();
    if (result != null) _expression = result;
  }
}

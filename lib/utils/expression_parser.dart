import 'dart:math' as math;
import '../models/calculator_mode.dart';
import 'calculator_logic.dart';

class ExpressionParser {
  final AngleMode angleMode;
  ExpressionParser({this.angleMode = AngleMode.degrees});

  String evaluate(String expression) {
    try {
      String expr = _preprocess(expression);
      double result = _parse(expr);
      return CalculatorLogic.formatResult(result, 10);
    } catch (e) {
      return 'Error';
    }
  }

  String _preprocess(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    expr = expr.replaceAll('π', '${math.pi}');
    expr = expr.replaceAll('e', '${math.e}');
    expr = expr.replaceAllMapped(
        RegExp(r'(\d)([\(a-zA-Z])'), (m) => '${m[1]}*${m[2]}');
    return expr;
  }

  double _parse(String expr) {
    expr = expr.trim();
    expr = _applyFunctions(expr);
    return _parseAddSub(expr);
  }

  String _applyFunctions(String expr) {
    final funcs = ['asin','acos','atan','sin','cos','tan','log2','log','ln','sqrt','cbrt','abs'];
    for (final fn in funcs) {
      while (expr.contains('$fn(')) {
        final idx = expr.indexOf('$fn(');
        final start = idx + fn.length;
        final end = _findClosing(expr, start);
        final inner = expr.substring(start + 1, end);
        final innerVal = _parse(inner);
        final result = _applyFunction(fn, innerVal);
        expr = expr.substring(0, idx) + result.toString() + expr.substring(end + 1);
      }
    }
    while (expr.contains('!')) {
      final idx = expr.indexOf('!');
      final numStr = _extractNumberBefore(expr, idx);
      final n = double.parse(numStr).toInt();
      final result = CalculatorLogic.factorial(n);
      final startIdx = idx - numStr.length;
      expr = expr.substring(0, startIdx) + result.toString() + expr.substring(idx + 1);
    }
    return expr;
  }

  double _applyFunction(String fn, double x) {
    switch (fn) {
      case 'sin': return CalculatorLogic.sin(x, angleMode);
      case 'cos': return CalculatorLogic.cos(x, angleMode);
      case 'tan': return CalculatorLogic.tan(x, angleMode);
      case 'asin': return CalculatorLogic.asin(x, angleMode);
      case 'acos': return CalculatorLogic.acos(x, angleMode);
      case 'atan': return CalculatorLogic.atan(x, angleMode);
      case 'log': return CalculatorLogic.log10(x);
      case 'log2': return CalculatorLogic.log2(x);
      case 'ln': return CalculatorLogic.ln(x);
      case 'sqrt': return CalculatorLogic.sqrt(x);
      case 'cbrt': return CalculatorLogic.cbrt(x);
      case 'abs': return x.abs();
      default: throw Exception('Unknown function: $fn');
    }
  }

  int _findClosing(String expr, int openIdx) {
    int count = 1;
    for (int i = openIdx + 1; i < expr.length; i++) {
      if (expr[i] == '(') count++;
      if (expr[i] == ')') count--;
      if (count == 0) return i;
    }
    throw Exception('Mismatched parentheses');
  }

  String _extractNumberBefore(String expr, int idx) {
    int i = idx - 1;
    while (i >= 0 && RegExp(r'[\d\.]').hasMatch(expr[i])) i--;
    return expr.substring(i + 1, idx);
  }

  double _parseAddSub(String expr) {
    expr = expr.trim();
    int i = expr.length - 1;
    int depth = 0;
    while (i >= 0) {
      if (expr[i] == ')') depth++;
      if (expr[i] == '(') depth--;

      // Tìm dấu + hoặc - nằm ngoài ngoặc đơn
      if (depth == 0 && i > 0) { // i > 0 để tránh nhầm với số âm ở đầu
        if (expr[i] == '+' || (expr[i] == '-' && !"+-*/^(".contains(expr[i-1]))) {
          return expr[i] == '+'
              ? _parseAddSub(expr.substring(0, i)) + _parseMulDiv(expr.substring(i + 1))
              : _parseAddSub(expr.substring(0, i)) - _parseMulDiv(expr.substring(i + 1));
        }
      }
      i--;
    }
    return _parseMulDiv(expr);
  }

  double _parseMulDiv(String expr) {
    expr = expr.trim();
    int i = expr.length - 1;
    int depth = 0;
    while (i >= 0) {
      if (expr[i] == ')') depth++;
      if (expr[i] == '(') depth--;
      if (depth == 0 && (expr[i] == '*' || expr[i] == '/') && i > 0) {
        return expr[i] == '*'
            ? _parsePow(expr.substring(0, i)) * _parseMulDiv(expr.substring(i + 1))
            : _parsePow(expr.substring(0, i)) / _parseMulDiv(expr.substring(i + 1));
      }
      i--;
    }
    return _parsePow(expr);
  }

  double _parsePow(String expr) {
    expr = expr.trim();
    final idx = expr.indexOf('^');
    if (idx > 0) {
      return math.pow(_parseUnary(expr.substring(0, idx)),
          _parsePow(expr.substring(idx + 1))).toDouble();
    }
    return _parseUnary(expr);
  }

  double _parseUnary(String expr) {
    expr = expr.trim();
    if (expr.startsWith('-')) return -_parseAtom(expr.substring(1));
    if (expr.startsWith('+')) return _parseAtom(expr.substring(1));
    return _parseAtom(expr);
  }

  double _parseAtom(String expr) {
    expr = expr.trim();
    if (expr.startsWith('(') && expr.endsWith(')'))
      return _parse(expr.substring(1, expr.length - 1));
    return double.parse(expr);
  }
}
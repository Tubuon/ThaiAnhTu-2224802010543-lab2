import 'dart:math' as math;
import '../models/calculator_mode.dart';

class CalculatorLogic {
  static double factorial(int n) {
    if (n < 0) throw Exception('Factorial undefined for negative numbers');
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  static double sin(double x, AngleMode mode) {
    final rad = mode == AngleMode.degrees ? x * math.pi / 180 : x;
    return math.sin(rad);
  }

  static double cos(double x, AngleMode mode) {
    final rad = mode == AngleMode.degrees ? x * math.pi / 180 : x;
    return math.cos(rad);
  }

  static double tan(double x, AngleMode mode) {
    final rad = mode == AngleMode.degrees ? x * math.pi / 180 : x;
    return math.tan(rad);
  }

  static double asin(double x, AngleMode mode) {
    final result = math.asin(x);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double acos(double x, AngleMode mode) {
    final result = math.acos(x);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double atan(double x, AngleMode mode) {
    final result = math.atan(x);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double log10(double x) => math.log(x) / math.ln10;
  static double log2(double x) => math.log(x) / math.log2e;
  static double ln(double x) => math.log(x);
  static double sqrt(double x) => math.sqrt(x);
  static double cbrt(double x) =>
      x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
  static double pow(double x, double y) => math.pow(x, y).toDouble();

  static String toHex(int n) => n.toRadixString(16).toUpperCase();
  static String toBin(int n) => n.toRadixString(2);
  static String toOct(int n) => n.toRadixString(8);

  static String formatResult(double value, int precision) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == value.truncateToDouble()) {
      final intVal = value.toInt();
      if (intVal.abs() < 1e15) return intVal.toString();
    }
    String result = value.toStringAsFixed(precision);
    result = result.replaceAll(RegExp(r'\.?0+$'), '');
    return result;
  }
}
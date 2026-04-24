import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_calculator/utils/calculator_logic.dart';
import 'package:advanced_calculator/utils/expression_parser.dart';
import 'package:advanced_calculator/models/calculator_mode.dart';

void main() {
  group('CalculatorLogic Tests', () {
    test('factorial 5 = 120', () {
      expect(CalculatorLogic.factorial(5), equals(120));
    });
    test('factorial 0 = 1', () {
      expect(CalculatorLogic.factorial(0), equals(1));
    });
    test('sin 90 degrees = 1', () {
      expect(CalculatorLogic.sin(90, AngleMode.degrees), closeTo(1.0, 0.0001));
    });
    test('cos 0 degrees = 1', () {
      expect(CalculatorLogic.cos(0, AngleMode.degrees), closeTo(1.0, 0.0001));
    });
    test('log10(100) = 2', () {
      expect(CalculatorLogic.log10(100), closeTo(2.0, 0.0001));
    });
    test('sqrt(9) = 3', () {
      expect(CalculatorLogic.sqrt(9), closeTo(3.0, 0.0001));
    });
    test('formatResult integer', () {
      expect(CalculatorLogic.formatResult(5.0, 6), equals('5'));
    });
  });

  group('ExpressionParser Tests', () {
    final parser = ExpressionParser(angleMode: AngleMode.degrees);

    test('(5+3)×2-4÷2 = 14', () {
      expect(parser.evaluate('(5+3)×2-4÷2'), equals('14'));
    });
    test('sin(45)+cos(45) ≈ 1.4142', () {
      final result = double.parse(parser.evaluate('sin(45)+cos(45)'));
      expect(result, closeTo(1.4142, 0.001));
    });
    test('2+3 = 5', () {
      expect(parser.evaluate('2+3'), equals('5'));
    });
    test('9-6+3 = 6', () {
      expect(parser.evaluate('9-6+3'), equals('6'));
    });
    test('nested parentheses ((2+3)×(4-1))÷5 = 3', () {
      expect(parser.evaluate('((2+3)×(4-1))÷5'), equals('3'));
    });
  });
}
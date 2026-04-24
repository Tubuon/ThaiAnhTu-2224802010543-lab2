import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import 'calculator_button.dart';
import '../utils/constants.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    switch (calc.mode) {
      case CalculatorMode.scientific:
        return const _ScientificGrid();
      case CalculatorMode.programmer:
        return const _ProgrammerGrid();
      default:
        return const _BasicGrid();
    }
  }
}

// ── Basic ────────────────────────────────────────────────────────────────────
class _BasicGrid extends StatelessWidget {
  const _BasicGrid();

  void _press(BuildContext context, String btn) {
    final calc = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();
    switch (btn) {
      case 'C': calc.clear(); break;
      case 'CE': calc.clearEntry(); break;
      case '⌫': calc.backspace(); break;
      case '%': calc.percent(); break;
      case '÷': case '×': case '-': case '+':
      calc.inputOperator(btn); break;
      case '=':
        final r = calc.evaluate();
        if (r != null) history.add(calc.previousResult, r);
        break;
      case '±': calc.toggleSign(); break;
      default: calc.input(btn);
    }
  }

  ButtonType _type(String btn) {
    if (btn == '=') return ButtonType.equal;
    if (['+', '-', '×', '÷'].contains(btn)) return ButtonType.operator;
    if (['C', 'CE', '⌫', '%', '±'].contains(btn)) return ButtonType.special;
    return ButtonType.number;
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['C', 'CE', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];
    return Column(
      children: rows.map((row) => Expanded(
        child: Row(
          children: row.map((btn) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.buttonSpacing / 2),
              child: CalculatorButton(
                label: btn,
                onPressed: () => _press(context, btn),
                type: _type(btn),
                fontSize: btn.length > 1 ? 16 : null,
              ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }
}

// ── Scientific ───────────────────────────────────────────────────────────────
class _Btn {
  final String label;
  final ButtonType type;
  final String? tap;
  final bool isActive;
  const _Btn(this.label, this.type, {this.tap, this.isActive = false});
}

class _ScientificGrid extends StatelessWidget {
  const _ScientificGrid();

  void _press(BuildContext context, String btn) {
    final calc = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();
    switch (btn) {
      case 'C': calc.clear(); break;
      case 'CE': calc.clearEntry(); break;
      case '⌫': calc.backspace(); break;
      case '÷': case '×': case '-': case '+':
      calc.inputOperator(btn); break;
      case '=':
        final r = calc.evaluate();
        if (r != null) history.add(calc.previousResult, r);
        break;
      case '±': calc.toggleSign(); break;
      case '%': calc.percent(); break;
      case '(': calc.openParen(); break;
      case ')': calc.closeParen(); break;
      case 'MC': calc.memoryClear(); break;
      case 'MR': calc.memoryRecall(); break;
      case 'M+': calc.memoryAdd(); break;
      case 'M-': calc.memorySubtract(); break;
      case 'x²': calc.square(); break;
      case '√': calc.squareRoot(); break;
      case '2nd': calc.toggleSecond(); break;
      case 'π': calc.inputConstant('π'); break;
      case 'e': calc.inputConstant('e'); break;
      case 'sin': calc.inputFunction(calc.isSecond ? 'asin' : 'sin'); break;
      case 'cos': calc.inputFunction(calc.isSecond ? 'acos' : 'cos'); break;
      case 'tan': calc.inputFunction(calc.isSecond ? 'atan' : 'tan'); break;
      case 'ln': calc.inputFunction('ln'); break;
      case 'log': calc.inputFunction('log'); break;
      case 'x^y': calc.inputOperator('^'); break;
      default: calc.input(btn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final s = calc.isSecond;
    final rows = [
      [_Btn('2nd', ButtonType.special, isActive: s),
        _Btn(s ? 'asin' : 'sin', ButtonType.function, tap: 'sin'),
        _Btn(s ? 'acos' : 'cos', ButtonType.function, tap: 'cos'),
        _Btn(s ? 'atan' : 'tan', ButtonType.function, tap: 'tan'),
        _Btn('ln', ButtonType.function),
        _Btn('log', ButtonType.function)],
      [_Btn('x²', ButtonType.function), _Btn('√', ButtonType.function),
        _Btn('x^y', ButtonType.function), _Btn('(', ButtonType.special),
        _Btn(')', ButtonType.special), _Btn('÷', ButtonType.operator)],
      [_Btn('MC', ButtonType.memory), _Btn('7', ButtonType.number),
        _Btn('8', ButtonType.number), _Btn('9', ButtonType.number),
        _Btn('C', ButtonType.special), _Btn('×', ButtonType.operator)],
      [_Btn('MR', ButtonType.memory), _Btn('4', ButtonType.number),
        _Btn('5', ButtonType.number), _Btn('6', ButtonType.number),
        _Btn('CE', ButtonType.special), _Btn('-', ButtonType.operator)],
      [_Btn('M+', ButtonType.memory), _Btn('1', ButtonType.number),
        _Btn('2', ButtonType.number), _Btn('3', ButtonType.number),
        _Btn('%', ButtonType.special), _Btn('+', ButtonType.operator)],
      [_Btn('M-', ButtonType.memory), _Btn('±', ButtonType.special),
        _Btn('0', ButtonType.number), _Btn('.', ButtonType.number),
        _Btn('π', ButtonType.function), _Btn('=', ButtonType.equal)],
    ];
    return Column(
      children: rows.map((row) => Expanded(
        child: Row(
          children: row.map((b) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.buttonSpacing / 2),
              child: CalculatorButton(
                label: b.label,
                onPressed: () => _press(context, b.tap ?? b.label),
                type: b.type,
                isActive: b.isActive,
                fontSize: b.label.length > 3 ? 12 : b.label.length > 2 ? 14 : null,
              ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }
}

// ── Programmer ───────────────────────────────────────────────────────────────
class _ProgrammerGrid extends StatelessWidget {
  const _ProgrammerGrid();

  void _press(BuildContext context, String btn) {
    final calc = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();
    switch (btn) {
      case 'C': calc.clear(); break;
      case '⌫': calc.backspace(); break;
      case '÷': case '×': case '-': case '+':
      calc.inputOperator(btn); break;
      case '=':
        final r = calc.evaluate();
        if (r != null) history.add(calc.previousResult, r);
        break;
      case 'AND': calc.inputOperator('&'); break;
      case 'OR': calc.inputOperator('|'); break;
      case 'XOR': calc.inputOperator('^'); break;
      default: calc.input(btn);
    }
  }

  ButtonType _type(String btn) {
    if (btn == '=') return ButtonType.equal;
    if (['+', '-', '×', '÷'].contains(btn)) return ButtonType.operator;
    if (['AND', 'OR', 'XOR', '<<', '>>'].contains(btn)) return ButtonType.function;
    if (['C', '⌫'].contains(btn)) return ButtonType.special;
    return ButtonType.number;
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final val = int.tryParse(calc.display) ??
        double.tryParse(calc.display)?.toInt() ?? 0;

    return Column(children: [
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          _ConvRow('HEX', '0x${val.toRadixString(16).toUpperCase()}'),
          _ConvRow('DEC', '$val'),
          _ConvRow('OCT', val.toRadixString(8)),
          _ConvRow('BIN', val.toRadixString(2)),
        ]),
      ),
      Expanded(child: Column(children: [
        _row(context, ['AND', 'OR', 'XOR', '÷']),
        _row(context, ['NOT', '<<', '>>', 'C']),
        _row(context, ['C', '⌫', '9', '×']),
        _row(context, ['7', '8', '9', '-']),
        _row(context, ['4', '5', '6', '+']),
        _row(context, ['1', '2', '3', '=']),
        _row(context, ['±', '0', '.', '=']),
      ])),
    ]);
  }

  Widget _row(BuildContext context, List<String> btns) {
    return Expanded(
      child: Row(
        children: btns.map((btn) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.buttonSpacing / 2),
            // THÊM GestureDetector để bắt sự kiện Long Press
            child: GestureDetector(
              onLongPress: btn == 'C' ? () {
                context.read<HistoryProvider>().clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa toàn bộ lịch sử'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } : null,
              child: CalculatorButton(
                label: btn,
                onPressed: () => _press(context, btn),
                type: _type(btn),
                fontSize: btn.length > 2 ? 13 : null,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _ConvRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConvRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 40,
            child: Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
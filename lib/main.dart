import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _historyDisplay = '';
  double _num1 = 0;
  String _operation = '';
  bool _justEvaluated = false;
  bool _waitingForNum2 = false;

  static const Color _bgColor     = Color(0xFF1C1C1C);
  static const Color _btnDark     = Color(0xFF2A2A2A);
  static const Color _btnOperator = Color(0xFF3A5A3A);
  static const Color _btnEquals   = Color(0xFF2E7D32);
  static const Color _btnClear    = Color(0xFFC62828);
  static const Color _textColor   = Colors.white;

  // Format số: bỏ .0 nếu là số nguyên
  String _fmt(double v) {
    if (v.isInfinite || v.isNaN) return 'Error';
    if (v == v.truncateToDouble() && v.abs() < 1e12) {
      return v.toInt().toString();
    }
    return double.parse(v.toStringAsPrecision(10)).toString();
  }

  // ── Nhấn số 0-9 ──────────────────────────────────────────────────
  void _onNumber(String digit) {
    setState(() {
      if (_justEvaluated) {
        _display = digit;
        _historyDisplay = '';
        _num1 = 0;
        _operation = '';
        _justEvaluated = false;
        _waitingForNum2 = false;
        return;
      }
      if (_waitingForNum2) {
        _display = digit;
        _waitingForNum2 = false;
        return;
      }
      if (_display == '0') {
        _display = digit;
      } else if (_display == '-0') {
        _display = '-$digit';
      } else {
        if (_display.replaceAll('-', '').replaceAll('.', '').length >= 12) return;
        _display += digit;
      }
    });
  }

  // ── Dấu thập phân ────────────────────────────────────────────────
  void _onDecimal() {
    setState(() {
      if (_justEvaluated || _waitingForNum2) {
        _display = '0.';
        _justEvaluated = false;
        _waitingForNum2 = false;
        return;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  // ── Phép tính (+, -, ×, ÷) ───────────────────────────────────────
  void _onOperation(String op) {
    setState(() {
      _justEvaluated = false;

      // FIX: Phép tính liên tiếp — tính kết quả trước
      if (_operation.isNotEmpty && !_waitingForNum2) {
        double num2 = double.tryParse(_display) ?? 0;
        double result = _calculate(_num1, num2, _operation);
        if (result.isInfinite || result.isNaN) {
          _display = 'Lỗi chia 0';
          _historyDisplay = '';
          _operation = '';
          _waitingForNum2 = false;
          return;
        }
        _num1 = result;
        _display = _fmt(result);
      } else {
        _num1 = double.tryParse(_display) ?? 0;
      }

      _operation = op;
      _historyDisplay = '${_fmt(_num1)} $op';
      _waitingForNum2 = true;
    });
  }

  // ── Tính toán ─────────────────────────────────────────────────────
  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷':
        if (b == 0) return double.infinity; // FIX: chia cho 0
        return a / b;
      default:  return b;
    }
  }

  // ── Nhấn = ───────────────────────────────────────────────────────
  void _onEquals() {
    if (_operation.isEmpty) return;
    setState(() {
      double num2 = double.tryParse(_display) ?? 0;
      double result = _calculate(_num1, num2, _operation);

      _historyDisplay = '${_fmt(_num1)} $_operation ${_fmt(num2)} =';

      if (result.isInfinite || result.isNaN) {
        // FIX: Hiện thông báo chia cho 0 rõ ràng
        _display = 'Lỗi chia 0';
      } else {
        _display = _fmt(result);
        _num1 = result;
      }

      _operation = '';
      _justEvaluated = true;
      _waitingForNum2 = false;
    });
  }

  // ── Xóa tất cả (C) ───────────────────────────────────────────────
  void _onClear() {
    setState(() {
      _display = '0';
      _historyDisplay = '';
      _num1 = 0;
      _operation = '';
      _justEvaluated = false;
      _waitingForNum2 = false;
    });
  }

  // ── Xóa chữ số cuối (CE) ─────────────────────────────────────────
  void _onCE() {
    setState(() {
      if (_display == 'Error' ||
          _display == 'Lỗi chia 0' ||
          _display.length <= 1 ||
          (_display.startsWith('-') && _display.length == 2)) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
        if (_display == '-' || _display.isEmpty) _display = '0';
      }
    });
  }

  // ── FIX: Đổi dấu +/− ─────────────────────────────────────────────
  // Trước: bấm +/- khi display = '0' → hiện '-0'
  // Sau:   chỉ đổi dấu khi có số thực sự
  void _onToggleSign() {
    setState(() {
      if (_display == '0' || _display == 'Lỗi chia 0' || _display == 'Error') return;
      if (_display.startsWith('-')) {
        _display = _display.substring(1); // Bỏ dấu -
      } else {
        _display = '-$_display'; // Thêm dấu -
      }
    });
  }

  // ── Phần trăm % ──────────────────────────────────────────────────
  void _onPercent() {
    setState(() {
      double val = double.tryParse(_display) ?? 0;
      _display = _fmt(val / 100);
    });
  }

  // ── Ngoặc () ─────────────────────────────────────────────────────
  void _onParenthesis() {
    setState(() {
      if (_display != 'Error' && _display != 'Lỗi chia 0') {
        _historyDisplay = '($_display)';
      }
    });
  }

  // ── Build UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Màn hình hiển thị
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_historyDisplay.isNotEmpty)
                      Text(
                        _historyDisplay,
                        style: const TextStyle(color: Colors.white38, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: TextStyle(
                          color: (_display == 'Error' || _display == 'Lỗi chia 0')
                              ? Colors.orange
                              : _textColor,
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lưới nút
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _row([
                      _btn('C',    _btnClear,    _onClear),
                      _btn('( )',  _btnDark,     _onParenthesis),
                      _btn('%',   _btnDark,     _onPercent),
                      _btn('÷',   _btnOperator, () => _onOperation('÷')),
                    ]),
                    _row([
                      _btn('7', _btnDark,     () => _onNumber('7')),
                      _btn('8', _btnDark,     () => _onNumber('8')),
                      _btn('9', _btnDark,     () => _onNumber('9')),
                      _btn('×', _btnOperator, () => _onOperation('×')),
                    ]),
                    _row([
                      _btn('4', _btnDark,     () => _onNumber('4')),
                      _btn('5', _btnDark,     () => _onNumber('5')),
                      _btn('6', _btnDark,     () => _onNumber('6')),
                      _btn('−', _btnOperator, () => _onOperation('-')),
                    ]),
                    _row([
                      _btn('1', _btnDark,     () => _onNumber('1')),
                      _btn('2', _btnDark,     () => _onNumber('2')),
                      _btn('3', _btnDark,     () => _onNumber('3')),
                      _btn('+', _btnOperator, () => _onOperation('+')),
                    ]),
                    _row([
                      _btn('+/−', _btnDark,   _onToggleSign),
                      _btn('0',   _btnDark,   () => _onNumber('0')),
                      _btn('.',   _btnDark,   _onDecimal),
                      _btn('=',   _btnEquals, _onEquals),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> btns) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: btns);

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: label.length > 2 ? 15 : 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
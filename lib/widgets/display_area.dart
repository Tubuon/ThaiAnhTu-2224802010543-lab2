import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';
import '../models/calculator_mode.dart';

class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppDimensions.displayRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _Chip(calc.mode.name.toUpperCase()),
                const SizedBox(width: 6),
                if (calc.mode == CalculatorMode.scientific)
                  _Chip(calc.angleMode == AngleMode.degrees ? 'DEG' : 'RAD'),
              ]),
              if (calc.hasMemory)
                _Chip('M: ${calc.memory.toStringAsFixed(2)}',
                    color: AppColors.memoryColor),
            ],
          ),
          const SizedBox(height: 12),
          if (calc.previousResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                calc.previousResult,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              key: ValueKey(calc.display),
              calc.display,
              style: TextStyle(
                fontSize: _fontSize(calc.display),
                fontWeight: FontWeight.w500,
                color: calc.hasError
                    ? Colors.red
                    : isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (calc.expression.isNotEmpty && calc.expression != calc.display)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                calc.expression,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  double _fontSize(String display) {
    if (display.length > 12) return 28;
    if (display.length > 8) return 36;
    return 48;
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  const _Chip(this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          )),
    );
  }
}
import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ButtonType { number, operator, equal, function, memory, special }

class CalculatorButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final VoidCallback onPressed;
  final ButtonType type;
  final double? fontSize;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.sublabel,
    this.type = ButtonType.number,
    this.fontSize,
    this.isActive = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.buttonPressAnimMs),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _bgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.type) {
      case ButtonType.operator:
        return isDark ? AppColors.operatorDarkColor : AppColors.operatorColor;
      case ButtonType.equal:
        return AppColors.equalColor;
      case ButtonType.function:
        return AppColors.scientificColor.withOpacity(0.85);
      case ButtonType.memory:
        return AppColors.memoryColor.withOpacity(0.85);
      case ButtonType.special:
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }

  Color _textColor(ButtonType type) {
    switch (type) {
      case ButtonType.operator:
      case ButtonType.equal:
      case ButtonType.function:
      case ButtonType.memory:
        return Colors.white;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isActive
                ? Theme.of(context).colorScheme.primary
                : _bgColor(context),
            borderRadius:
            BorderRadius.circular(AppDimensions.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: widget.sublabel != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.label,
                    style: TextStyle(
                      fontSize: widget.fontSize ?? 18,
                      fontWeight: FontWeight.w600,
                      color: _textColor(widget.type),
                    )),
                Text(widget.sublabel!,
                    style: TextStyle(
                      fontSize: 10,
                      color: _textColor(widget.type).withOpacity(0.7),
                    )),
              ],
            )
                : Text(widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize ?? 20,
                  fontWeight: FontWeight.w600,
                  color: _textColor(widget.type),
                )),
          ),
        ),
      ),
    );
  }
}
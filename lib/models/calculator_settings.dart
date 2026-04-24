import 'calculator_mode.dart';

class CalculatorSettings {
  final AngleMode angleMode;
  final int decimalPrecision;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;

  const CalculatorSettings({
    this.angleMode = AngleMode.degrees,
    this.decimalPrecision = 6,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
  });

  CalculatorSettings copyWith({
    AngleMode? angleMode,
    int? decimalPrecision,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
  }) {
    return CalculatorSettings(
      angleMode: angleMode ?? this.angleMode,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
    );
  }
}

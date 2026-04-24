class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) =>
      CalculationHistory(
        expression: json['expression'],
        result: json['result'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

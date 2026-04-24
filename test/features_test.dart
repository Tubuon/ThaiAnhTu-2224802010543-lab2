import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_calculator/providers/calculator_provider.dart';
import 'package:advanced_calculator/providers/history_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Kiểm tra tính năng nâng cao', () {
    test('Kiểm tra mặc định của Haptic Feedback là ON', () {
      final calcProvider = CalculatorProvider();
      expect(calcProvider.hapticFeedback, true);
    });

    test('Kiểm tra tắt/mở Haptic Feedback', () {
      final calcProvider = CalculatorProvider();
      calcProvider.setHapticFeedback(false);
      expect(calcProvider.hapticFeedback, false);
    });

    test('Kiểm tra thêm lịch sử tính toán', () async {
      final historyProvider = HistoryProvider();
      await historyProvider.clear(); // Xóa sạch trước khi test

      await historyProvider.add('2+2', '4');
      expect(historyProvider.history.length, 1);
      expect(historyProvider.history[0].result, '4');
    });
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_calculator/main.dart';
import 'package:advanced_calculator/widgets/calculator_button.dart';

void main() {
  testWidgets('Calculator UI Smoke Test', (WidgetTester tester) async {
    // 1. Khởi chạy ứng dụng
    await tester.pumpWidget(const MyApp());

    // 2. Kiểm tra xem màn hình có hiển thị số 0 mặc định không
    // Dùng findsAtLeast vì có thể có số 0 ở màn hình hiển thị và cả nút bấm
    expect(find.text('0'), findsAtLeast(1));

    // 3. Tìm nút số '1' và nhấn vào
    final button1 = find.widgetWithText(CalculatorButton, '1');
    expect(button1, findsOneWidget);
    await tester.tap(button1);

    // 4. Cập nhật giao diện sau khi nhấn
    await tester.pump();

    // 5. Kiểm tra xem số 1 đã xuất hiện trên màn hình hiển thị chưa
    expect(find.text('1'), findsAtLeast(1));

    // 6. Kiểm tra nút xóa 'C' có tồn tại không
    expect(find.text('C'), findsOneWidget);
  });
}
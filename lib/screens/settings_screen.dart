import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final history = context.watch<HistoryProvider>();
    final calc = context.watch<CalculatorProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // --- THEME ---
          const _SectionHeader('Giao diện'),
          ListTile(
            title: const Text('Chủ đề'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Sáng')),
                ButtonSegment(value: ThemeMode.system, label: Text('Tự động')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Tối')),
              ],
              selected: {theme.themeMode},
              onSelectionChanged: (s) => theme.setThemeMode(s.first),
            ),
          ),

          // --- DECIMAL PRECISION ---
          const _SectionHeader('Tính toán'),
          ListTile(
            title: Text('Độ chính xác thập phân: ${calc.decimalPrecision}'),
            subtitle: Slider(
              value: calc.decimalPrecision.toDouble(),
              min: 2, max: 10, divisions: 8,
              label: '${calc.decimalPrecision}',
              onChanged: (v) => calc.setDecimalPrecision(v.toInt()),
            ),
          ),
          ListTile(
            title: const Text('Chế độ góc'),
            trailing: SegmentedButton<AngleMode>(
              segments: const [
                ButtonSegment(value: AngleMode.degrees, label: Text('DEG')),
                ButtonSegment(value: AngleMode.radians, label: Text('RAD')),
              ],
              selected: {calc.angleMode},
              onSelectionChanged: (s) => calc.setAngleMode(s.first),
            ),
          ),

          // --- HISTORY ---
          const _SectionHeader('Lịch sử'),
          ListTile(
            title: const Text('Số lượng lưu trữ'),
            trailing: DropdownButton<int>(
              value: history.historySize,
              items: [25, 50, 100]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (v) => history.setHistorySize(v!),
            ),
          ),
          ListTile(
            title: const Text('Xóa toàn bộ lịch sử',
                style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmClear(context),
          ),

          // --- FEEDBACK ---
          const _SectionHeader('Phản hồi'),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Rung nhẹ khi nhấn phím'),
            value: calc.hapticFeedback, // Đã kết nối với Provider
            onChanged: (val) => calc.setHapticFeedback(val),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: false,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<HistoryProvider>().clear();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary)),
  );
}
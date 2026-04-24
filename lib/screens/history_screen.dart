import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tính toán'),
        actions: [
          if (history.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: history.history.isEmpty
          ? const Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có lịch sử',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ]))
          : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.history.length,
          itemBuilder: (context, index) {
            final item = history.history[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.expression,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                subtitle: Text('= ${item.result}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                trailing: Text(_formatTime(item.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  context.read<CalculatorProvider>().inputConstant(item.result);
                  Navigator.pop(context);
                },
              ),
            );
          }),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${dt.day}/${dt.month}';
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

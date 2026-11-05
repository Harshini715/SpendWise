import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final Map<String, double> totals = {};

    for (var e in provider.expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: totals.isEmpty
          ? const Center(child: Text('No data yet'))
          : ListView(
              children: totals.entries.map((entry) {
                final percent = provider.totalAmount == 0
                    ? 0.0
                    : entry.value / provider.totalAmount;
                return ListTile(
                  title: Text(entry.key),
                  subtitle: LinearProgressIndicator(value: percent),
                  trailing: Text('₹${entry.value.toStringAsFixed(0)}'),
                );
              }).toList(),
            ),
    );
  }
}

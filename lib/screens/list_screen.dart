import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'detail_screen.dart';
import 'form_screen.dart';
import 'summary_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ExpenseProvider>(context, listen: false).loadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ExpenseProvider provider) {
    // 1. Loading State
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State + Retry
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.loadExpenses(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // 3. Empty State
    if (provider.expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet\n+ button tho add cheyandi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // 4. Data State
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.teal.shade50,
          child: Text(
            'Total: ₹${provider.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final e = provider.expenses[index];
              return ListTile(
                leading: CircleAvatar(child: Text(e.category[0])),
                title: Text(e.note.isEmpty ? e.category : e.note),
                subtitle: Text('${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}'),
                trailing: Text('₹${e.amount.toStringAsFixed(0)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(expense: e)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

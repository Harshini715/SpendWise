import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Expense {
  final String id, title, category, note;
  final double amount;
  final DateTime date;
  Expense({required this.id, required this.title, required this.amount, required this.category, required this.date, required this.note});
}

class ExpenseStore extends ChangeNotifier {
  List<Expense> expenses = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMsg = '';

  Future<void> load() async {
    isLoading = true;
    hasError = false;
    await Future.delayed(const Duration(seconds: 1));
    try {
      isLoading = false;
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMsg = 'Could not load';
    }
    notifyListeners();
  }

  void add(String title, double amount, String category, DateTime date, String note) {
    expenses.insert(0, Expense(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title.trim(), amount: amount, category: category, date: date, note: note.trim()));
    notifyListeners();
  }

  void delete(String id) {
    expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  double get total => expenses.fold(0, (s, e) => s + e.amount);

  Map<String, double> get byCategory {
    final m = <String, double>{};
    for (final e in expenses) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }
}

final store = ExpenseStore();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpendWise',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => store.load());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SpendWise'),
            actions: [IconButton(icon: const Icon(Icons.pie_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen())))],
          ),
          body: _body(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  Widget _body() {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());
    if (store.hasError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(store.errorMsg), const SizedBox(height: 12), ElevatedButton(onPressed: () => store.load(), child: const Text('Retry'))]));
    if (store.expenses.isEmpty) return const Center(child: Text('No expenses yet.\nTap + to add your first expense.', textAlign: TextAlign.center));
    return Column(
      children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.teal.shade50, child: Text('Total Spent: ₹${store.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Expanded(child: ListView.builder(itemCount: store.expenses.length, itemBuilder: (c, i) {
          final e = store.expenses[i];
          return ListTile(title: Text(e.title), subtitle: Text('${e.category} • ${DateFormat('dd MMM yyyy').format(e.date)}'), trailing: Text('₹${e.amount.toStringAsFixed(2)}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(expense: e))));
        })),
      ],
    );
  }
}
class DetailScreen extends StatelessWidget {
  final Expense expense;
  const DetailScreen({super.key, required this.expense});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Amount: ₹${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
            Text('Category: ${expense.category}'),
            Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(expense.date)}'),
            const SizedBox(height: 12),
            Text('Note: ${expense.note.isEmpty ? 'No note added' : expense.note}'),
            const Spacer(),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { store.delete(expense.id); Navigator.pop(context); }, icon: const Icon(Icons.delete), label: const Text('Delete Expense'))),
          ],
        ),
      ),
    );
  }
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _cat = 'Food';
  DateTime _date = DateTime.now();
  final _cats = ['Food', 'Travel', 'Shopping', 'Bills', 'Health', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()), validator: (v) { if (v == null || v.trim().isEmpty) return 'Please enter a title'; if (v.trim().length < 3) return 'Title must be at least 3 characters'; return null; }),
            const SizedBox(height: 12),
            TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹) *', border: OutlineInputBorder()), validator: (v) { if (v == null || v.trim().isEmpty) return 'Please enter amount'; final n = double.tryParse(v.trim()); if (n == null) return 'Enter a valid number'; if (n <= 0) return 'Amount must be greater than 0'; return null; }),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _cat, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()), items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _cat = v!)),
            const SizedBox(height: 12),
            TextFormField(controller: _note, maxLength: 100, decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder())),
            ListTile(title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'), trailing: const Icon(Icons.calendar_today), onTap: () async { final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => _date = p); }),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () { if (!_key.currentState!.validate()) return; store.add(_title.text, double.parse(_amount.text), _cat, _date, _note.text); Navigator.pop(context); }, child: const Text('Save Expense')),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        final totals = store.byCategory;
        return Scaffold(
          appBar: AppBar(title: const Text('Summary')),
          body: totals.isEmpty
              ? const Center(child: Text('No data to show yet.'))
              : ListView(children: [
                  ListTile(title: const Text('Total Expenses'), trailing: Text('₹${store.total.toStringAsFixed(2)}')),
                  const Divider(),
                  ...totals.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('₹${e.value.toStringAsFixed(2)}'))),
                ]),
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalAmount {
    double total = 0;
    for (var e in _expenses) {
      total += e.amount;
    }
    return total;
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('expenses');
      if (data != null) {
        final List list = jsonDecode(data);
        _expenses = list.map((e) => Expense.fromJson(e)).toList();
      } else {
        _expenses = [];
      }
    } catch (e) {
      _error = 'Data load avvaledu. Malli try cheyandi.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _save();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString('expenses', data);
  }
}

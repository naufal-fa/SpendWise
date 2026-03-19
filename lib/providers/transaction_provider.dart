import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart';

enum TransactionTypeFilter { all, income, expense }

class TransactionProvider extends ChangeNotifier {
  final List<TransactionItem> _transactions = [];
  String _searchQuery = '';
  TransactionTypeFilter _typeFilter = TransactionTypeFilter.all;
  String? _categoryFilter;
  double? _minAmount;
  double? _maxAmount;
  DateTime? _monthFilter;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('transactions_data');
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions.clear();
        for (var item in decoded) {
          _transactions.add(TransactionItem.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load transactions: $e');
    }
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_transactions.map((tx) => tx.toJson()).toList());
      await prefs.setString('transactions_data', encoded);
    } catch (e) {
      debugPrint('Failed to save transactions: $e');
    }
  }

  String get searchQuery => _searchQuery;
  TransactionTypeFilter get typeFilter => _typeFilter;
  String? get categoryFilter => _categoryFilter;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  DateTime? get monthFilter => _monthFilter;

  bool get hasActiveFilters =>
      _typeFilter != TransactionTypeFilter.all ||
      _categoryFilter != null ||
      _minAmount != null ||
      _maxAmount != null ||
      _monthFilter != null ||
      _searchQuery.isNotEmpty;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(TransactionTypeFilter filter) {
    _typeFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setAmountRange(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    notifyListeners();
  }

  void setMonthFilter(DateTime? month) {
    _monthFilter = month;
    notifyListeners();
  }

  void clearFilters() {
    _typeFilter = TransactionTypeFilter.all;
    _categoryFilter = null;
    _minAmount = null;
    _maxAmount = null;
    _monthFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  List<TransactionItem> get transactions =>
      List.unmodifiable(_transactions);

  /// Returns transactions sorted by date (newest first)
  List<TransactionItem> get sortedTransactions {
    List<TransactionItem> filtered = _transactions;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((tx) {
        final matchesCategory = tx.categoryLabel.toLowerCase().contains(query);
        final matchesNote = tx.note?.toLowerCase().contains(query) ?? false;
        final matchesAmount = tx.amount.toString().contains(query);
        return matchesCategory || matchesNote || matchesAmount;
      }).toList();
    }

    if (_typeFilter != TransactionTypeFilter.all) {
      final isIncomeFilter = _typeFilter == TransactionTypeFilter.income;
      filtered = filtered.where((tx) => tx.isIncome == isIncomeFilter).toList();
    }

    if (_categoryFilter != null) {
      filtered = filtered.where((tx) => tx.categoryLabel == _categoryFilter).toList();
    }

    if (_minAmount != null) {
      filtered = filtered.where((tx) => tx.amount >= _minAmount!).toList();
    }

    if (_maxAmount != null) {
      filtered = filtered.where((tx) => tx.amount <= _maxAmount!).toList();
    }

    if (_monthFilter != null) {
      filtered = filtered.where((tx) => tx.date.year == _monthFilter!.year && tx.date.month == _monthFilter!.month).toList();
    }

    final sorted = List<TransactionItem>.from(filtered);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Groups transactions by date (returns map of date label → transactions)
  Map<String, List<TransactionItem>> get groupedByDate {
    final sorted = sortedTransactions;
    final map = <String, List<TransactionItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in sorted) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String label;

      if (txDate == today) {
        label = 'TODAY';
      } else if (txDate == yesterday) {
        label = 'YESTERDAY';
      } else {
        // e.g. "MON, 18 MAR 2026"
        const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
        const months = [
          'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
          'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
        ];
        label =
            '${days[txDate.weekday - 1]}, ${txDate.day} ${months[txDate.month - 1]} ${txDate.year}';
      }

      map.putIfAbsent(label, () => []);
      map[label]!.add(tx);
    }

    return map;
  }

  void addTransaction(TransactionItem transaction) {
    _transactions.add(transaction);
    _checkBudgetAlert();
    _saveTransactions();
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    _checkBudgetAlert();
    _saveTransactions();
    notifyListeners();
  }

  void updateTransaction(TransactionItem updatedTx) {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      _checkBudgetAlert();
      _saveTransactions();
      notifyListeners();
    }
  }

  void _checkBudgetAlert() {
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in _transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    NotificationService().showBudgetAlertIfNeeded(totalIncome - totalExpense);
  }
}

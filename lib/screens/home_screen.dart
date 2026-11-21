import 'package:flutter/material.dart';

import '../data/expense_database.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _database = ExpenseDatabase.instance;
  List<Expense> _expenses = [];
  double _total = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _database.getExpenses();
      final total = await _database.getTotalExpenses();
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
        _total = total;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load expenses. Please try again.';
      });
    }
  }

  Future<void> _openAddExpense() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (saved == true) _loadExpenses();
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Delete "${expense.title}" from your expenses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || expense.id == null) return;
    await _database.deleteExpense(expense.id!);
    await _loadExpenses();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }

  String _money(double value) => '৳${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadExpenses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExpenses,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total expenses',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            const SizedBox(height: 8),
                            Text(
                              _money(_total),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Saved expenses',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      if (_expenses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 55),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 54, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No expenses yet',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 5),
                              Text('Tap + to add your first expense',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      else
                        ..._expenses.map(
                          (expense) => Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 4, top: 4, bottom: 4),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: const Icon(Icons.receipt_long),
                              ),
                              title: Text(
                                expense.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(_money(expense.amount)),
                              trailing: IconButton(
                                tooltip: 'Delete expense',
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _deleteExpense(expense),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpense,
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final Car car;

  const ExpenseListScreen({super.key, required this.car});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pl_PL', symbol: 'zł');
  
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _databaseService.getExpenses(widget.car.carStatisticsTable);
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd ładowania wydatków: $e')),
        );
      }
    }
  }

  void _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(car: widget.car),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  void _editExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(car: widget.car, expense: expense),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  void _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń wydatek'),
        content: Text('Czy na pewno chcesz usunąć wydatek "${expense.statisticTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteExpense(widget.car.carStatisticsTable, expense.id!);
        _loadExpenses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wydatek został usunięty')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd usuwania wydatku: $e')),
          );
        }
      }
    }
  }

  Color _getCategoryColor(int type) {
    switch (type) {
      case 1: return Colors.red; // Akumulator
      case 2: return Colors.orange; // Naprawa
      case 3: return Colors.blue; // Laweta
      case 4: return Colors.green; // Ubezpieczenie
      case 5: return Colors.purple; // Przegląd
      default: return Colors.grey; // Inne
    }
  }

  IconData _getCategoryIcon(int type) {
    switch (type) {
      case 1: return Icons.battery_full; // Akumulator
      case 2: return Icons.build; // Naprawa
      case 3: return Icons.local_shipping; // Laweta
      case 4: return Icons.security; // Ubezpieczenie
      case 5: return Icons.verified_user; // Przegląd
      default: return Icons.receipt; // Inne
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wydatki - ${widget.car.carAliasName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Brak wydatków',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Dodaj pierwszy wydatek używając przycisku poniżej',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExpenses,
                  child: Column(
                    children: [
                      // Podsumowanie wydatków
                      if (_expenses.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Łączny koszt',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _currencyFormat.format(
                                      _expenses.fold(0.0, (sum, expense) => sum + expense.statisticCost),
                                    ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Liczba wydatków',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_expenses.length}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      // Lista wydatków
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            return Card(
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getCategoryColor(expense.statisticType),
                                  child: Icon(
                                    _getCategoryIcon(expense.statisticType),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  expense.statisticTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${expense.typeName} • ${DateFormat('dd.MM.yyyy').format(expense.date)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currencyFormat.format(expense.statisticCost),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _editExpense(expense);
                                            break;
                                          case 'delete':
                                            _deleteExpense(expense);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edytuj'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),
                                              SizedBox(width: 8),
                                              Text('Usuń'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Data: ${DateFormat('dd.MM.yyyy HH:mm').format(expense.date)}',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.category,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Kategoria: ${expense.typeName}',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        if (expense.information != null && expense.information!.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              expense.information!,
                                              style: const TextStyle(color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text('Ocena: '),
                                            ...List.generate(5, (i) => Icon(
                                              i < expense.statisticRating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        tooltip: 'Dodaj wydatek',
        child: const Icon(Icons.add),
      ),
    );
  }
}
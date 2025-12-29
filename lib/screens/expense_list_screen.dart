import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import 'expense_form_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/expense_type_helper.dart';

class ExpenseListScreen extends StatefulWidget {
  final Car car;

  const ExpenseListScreen({super.key, required this.car});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final DatabaseService _databaseService = DatabaseService();

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
      final expenses = await _databaseService.getExpenses(
        widget.car.carStatisticsTable,
      );
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingExpenses(e.toString()),
            ),
          ),
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
        builder: (context) =>
            ExpenseFormScreen(car: widget.car, expense: expense),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  void _deleteExpense(Expense expense) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExpense),
        content: Text(l10n.confirmDeleteExpense(expense.statisticTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteExpense(
          widget.car.carStatisticsTable,
          expense.id!,
        );
        _loadExpenses();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.expenseDeleted)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.errorDeletingExpense(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  Color _getCategoryColor(int type) {
    switch (type) {
      case 1:
        return Colors.red; // Maintenance
      case 2:
        return Colors.orange; // Repair
      case 3:
        return Colors.blue; // Towning
      case 4:
        return Colors.green; // Insurance
      case 5:
        return Colors.purple; // Inspection
      default:
        return Colors.grey; // Other
    }
  }

  IconData _getCategoryIcon(int type) {
    switch (type) {
      case 1:
        return Icons.build_circle; // Maintenance
      case 2:
        return Icons.build; // Repair
      case 3:
        return Icons.local_shipping; // Twoning
      case 4:
        return Icons.security; // Insurance
      case 5:
        return Icons.verified_user; // Inspection
      default:
        return Icons.receipt; // Other
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.recentExpenses} - ${widget.car.carAliasName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    l10n.noExpenses,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.addFirstExpense,
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
                  // Expense summary
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
                              Text(
                                l10n.totalCost,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                currencyService.formatCurrency(
                                  _expenses.fold(
                                    0.0,
                                    (sum, expense) =>
                                        sum + expense.statisticCost,
                                  ),
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
                              Text(
                                l10n.numberOfExpenses,
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

                  // Expense list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                expense.statisticType,
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.statisticType),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              expense.statisticTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${ExpenseTypeHelper.getLocalizedTypeName(l10n, expense.statisticType)} • ${DateFormat('dd.MM.yyyy').format(expense.date)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currencyService.formatCurrency(
                                    expense.statisticCost,
                                  ),
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
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text(l10n.edit),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete),
                                          SizedBox(width: 8),
                                          Text(l10n.delete),
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
                                          '${l10n.dateLabel} ${DateFormat('dd.MM.yyyy HH:mm').format(expense.date)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
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
                                          '${l10n.category}: ${ExpenseTypeHelper.getLocalizedTypeName(l10n, expense.statisticType)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (expense.information != null &&
                                        expense.information!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          expense.information!,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('${l10n.ratingLabel} '),
                                        ...List.generate(
                                          5,
                                          (i) => Icon(
                                            i < expense.statisticRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                        ),
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
        tooltip: l10n.addExpenseTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

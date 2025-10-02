import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/expense_type_helper.dart';
import 'refuel_form_screen.dart';
import 'expense_form_screen.dart';
import 'refuel_list_screen.dart';
import 'expense_list_screen.dart';
import 'statistics_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pl_PL', symbol: 'zł');
  final NumberFormat _numberFormat = NumberFormat('#,##0.0', 'pl_PL');
  
  List<Refuel> _recentRefuels = [];
  List<Expense> _recentExpenses = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final refuels = await _databaseService.getRefuels(widget.car.carName, limit: 5);
      final expenses = await _databaseService.getExpenses(widget.car.carStatisticsTable, limit: 5);
      final stats = await _databaseService.getRefuelStatistics(widget.car.carName, 10);
      
      setState(() {
        _recentRefuels = refuels;
        _recentExpenses = expenses;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  void _addRefuel() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefuelFormScreen(car: widget.car),
      ),
    );
    if (result == true) {
      _loadData();
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
      _loadData();
    }
  }

  void _showAllRefuels() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefuelListScreen(car: widget.car),
      ),
    );
  }

  void _showAllExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseListScreen(car: widget.car),
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(car: widget.car),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.carAliasName ?? widget.car.carName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatistics,
            tooltip: AppLocalizations.of(context)!.statistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Karta z podstawowymi statystykami
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.lastRefuels,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  AppLocalizations.of(context)!.avgConsumption,
                                  '${_numberFormat.format(_statistics['avgConsumption'] ?? 0)} l/100km',
                                  Icons.local_gas_station,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  AppLocalizations.of(context)!.avgPrice,
                                  '${_numberFormat.format(_statistics['avgPricePerLiter'] ?? 0)} zł/l',
                                  Icons.attach_money,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  AppLocalizations.of(context)!.distance,
                                  '${_numberFormat.format(_statistics['totalDistance'] ?? 0)} km',
                                  Icons.route,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  AppLocalizations.of(context)!.fuelCosts,
                                  _currencyFormat.format(_statistics['totalCost'] ?? 0),
                                  Icons.receipt,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ostatnie tankowania
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(l10n.recentRefuels),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _showAllRefuels,
                                child: Text(l10n.viewAll),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addRefuel,
                              ),
                            ],
                          ),
                        ),
                        if (_recentRefuels.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.noRefuels),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentRefuels.length,
                            itemBuilder: (context, index) {
                              final refuel = _recentRefuels[index];
                              return ListTile(
                                leading: const Icon(Icons.local_gas_station),
                                title: Text('${_numberFormat.format(refuel.volumes)} l'),
                                subtitle: Text(DateFormat('dd.MM.yyyy').format(refuel.date)),
                                trailing: Text(_currencyFormat.format(refuel.prize)),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ostatnie wydatki
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(l10n.recentExpenses),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _showAllExpenses,
                                child: Text(l10n.viewAll),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addExpense,
                              ),
                            ],
                          ),
                        ),
                        if (_recentExpenses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(l10n.noExpenses),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = _recentExpenses[index];
                              return ListTile(
                                leading: const Icon(Icons.build),
                                title: Text(expense.statisticTitle),
                                subtitle: Text('${ExpenseTypeHelper.getLocalizedTypeName(l10n, expense.statisticType)} • ${DateFormat('dd.MM.yyyy').format(expense.date)}'),
                                trailing: Text(_currencyFormat.format(expense.statisticCost)),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'expense',
            onPressed: _addExpense,
            tooltip: AppLocalizations.of(context)!.addExpense,
            child: const Icon(Icons.build),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refuel',
            onPressed: _addRefuel,
            tooltip: AppLocalizations.of(context)!.addRefuel,
            child: const Icon(Icons.local_gas_station),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/expense_type_helper.dart';
import 'refuel_form_screen.dart';
import 'expense_form_screen.dart';
import 'refuel_list_screen.dart';
import 'expense_list_screen.dart';
import 'statistics_screen.dart';
import 'home_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SettingsService _settingsService = SettingsService();
  final NumberFormat _numberFormat = NumberFormat('#,##0.0', 'pl_PL');

  List<Refuel> _recentRefuels = [];
  List<Expense> _recentExpenses = [];
  Map<String, dynamic> _statistics = {};
  int _statisticsRange = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final statisticsRange = await _settingsService.getStatisticsRange();
      final limit = statisticsRange == 0 ? 999999 : statisticsRange;
      final refuels = await _databaseService.getRefuels(
        widget.car.carName,
        limit: 5,
      );
      final expenses = await _databaseService.getExpenses(
        widget.car.carStatisticsTable,
        limit: 5,
      );
      final stats = await _databaseService.getRefuelStatistics(
        widget.car.carName,
        limit,
      );

      setState(() {
        _recentRefuels = refuels;
        _recentExpenses = expenses;
        _statistics = stats;
        _statisticsRange = statisticsRange;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingData(e.toString()),
            ),
          ),
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

  void _showAllRefuels() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefuelListScreen(car: widget.car),
      ),
    );
    // Reload data in case refuels were added, edited, or deleted
    _loadData();
  }

  void _showAllExpenses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseListScreen(car: widget.car),
      ),
    );
    // Reload data in case expenses were added, edited, or deleted
    _loadData();
  }

  void _showStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(car: widget.car),
      ),
    );
    // Reload data in case statistics range was changed
    _loadData();
  }

  void _changeCar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.carAliasName ?? widget.car.carName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: _changeCar,
            tooltip: l10n.changeCar,
          ),
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
                            _statisticsRange == 0
                                ? '${l10n.all} ${l10n.refuels.toLowerCase()}'
                                : _statisticsRange == -1
                                ? '${DateTime.now().year} ${l10n.refuels.toLowerCase()}'
                                : _statisticsRange == -2
                                ? '${DateTime.now().year - 1} ${l10n.refuels.toLowerCase()}'
                                : '${l10n.last10.replaceAll('10', _statisticsRange.toString())} ${l10n.refuels.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  currencyService.formatPricePerLiter(
                                    _statistics['avgPricePerLiter'] ?? 0,
                                  ),
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
                                  currencyService.formatCurrency(
                                    _statistics['totalCost'] ?? 0,
                                  ),
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
                                title: Text(
                                  '${_numberFormat.format(refuel.volumes)} l',
                                ),
                                subtitle: Text(
                                  DateFormat('dd.MM.yyyy').format(refuel.date),
                                ),
                                trailing: Text(
                                  currencyService.formatCurrency(
                                    refuel.totalCost,
                                  ),
                                ),
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
                                subtitle: Text(
                                  '${ExpenseTypeHelper.getLocalizedTypeName(l10n, expense.statisticType)} • ${DateFormat('dd.MM.yyyy').format(expense.date)}',
                                ),
                                trailing: Text(
                                  currencyService.formatCurrency(
                                    expense.statisticCost,
                                  ),
                                ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/refuel_type.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  final Car car;

  const StatisticsScreen({super.key, required this.car});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SettingsService _settingsService = SettingsService();

  int _selectedRange = 10; // Default: last 10
  Map<String, dynamic> _refuelStats = {};
  Map<String, dynamic> _expenseStats = {};
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  List<int> _rangeOptions = [
    5,
    10,
    0,
  ]; // 0 means all, positive numbers mean last N refuelings, negative numbers represent years
  List<int> _availableYears = []; // Store all available years for picker
  static const int _yearPickerOption =
      -999999; // Special value to trigger year picker

  String _getRangeLabel(int range, AppLocalizations l10n) {
    if (range == _yearPickerOption) {
      return 'Select year...';
    } else if (range > 0) {
      // Positive numbers: last N refuelings
      if (range == 5) return l10n.last5;
      if (range == 10) return l10n.last10;
      return '${l10n.last10} $range';
    } else if (range < 0) {
      // Negative numbers: year (e.g., -2025 represents year 2025)
      return '${-range}';
    } else {
      // 0 means all
      return l10n.all;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableYears();
  }

  Future<void> _loadAvailableYears() async {
    try {
      // Load all refuels to extract available years
      final refuels = await _databaseService.getRefuels(widget.car.carName);
      final years = refuels.map((r) => r.date.year).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      _availableYears = years;

      // Load saved range and start loading statistics
      await _loadSavedRange();

      // Build range options after loading saved range to ensure selected year is included
      _updateRangeOptions();
    } catch (e) {
      // If loading years fails, continue with default options
      await _loadSavedRange();
    }
  }

  void _updateRangeOptions() {
    // Build range options: [5, 10] + recent 3 years + selected year (if not recent) + "Select year..." + [0]
    final recentYears = _availableYears.take(3).map((year) => -year).toSet();
    final needsYearPicker = _availableYears.length > 3;

    // If selected range is a year not in recent years, add it
    if (_selectedRange < 0 &&
        _selectedRange != _yearPickerOption &&
        !recentYears.contains(_selectedRange)) {
      recentYears.add(_selectedRange);
    }

    final sortedYears = recentYears.toList()..sort();

    setState(() {
      _rangeOptions = [
        5,
        10,
        ...sortedYears,
        if (needsYearPicker) _yearPickerOption,
        0,
      ];
    });
  }

  Future<void> _loadSavedRange() async {
    final savedRange = await _settingsService.getStatisticsRange();
    setState(() {
      _selectedRange = savedRange;
    });
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      // For all data or any specific year, fetch all and filter by date
      final count = (_selectedRange <= 0) ? 999999 : _selectedRange;

      var refuelStats = await _databaseService.getRefuelStatistics(
        widget.car.carName,
        count,
      );
      var expenseStats = await _databaseService.getExpenseStatistics(
        widget.car.carStatisticsTable,
        count,
      );
      var chartData = await _databaseService.getRefuelChartData(
        widget.car.carName,
        count,
      );

      // Filter by specific year if selected (negative range values represent years)
      if (_selectedRange < 0) {
        final targetYear = -_selectedRange;
        final refuels = await _databaseService.getRefuels(widget.car.carName);
        final expenses = await _databaseService.getExpenses(
          widget.car.carStatisticsTable,
        );

        final yearRefuels = refuels
            .where((r) => r.date.year == targetYear)
            .toList();
        final yearExpenses = expenses
            .where((e) => e.date.year == targetYear)
            .toList();

        // Recalculate stats for current year data
        if (yearRefuels.isNotEmpty) {
          refuelStats = await _databaseService.getRefuelStatistics(
            widget.car.carName,
            yearRefuels.length,
          );
          chartData = await _databaseService.getRefuelChartData(
            widget.car.carName,
            yearRefuels.length,
          );
        } else {
          refuelStats = {
            'count': 0,
            'totalVolume': 0.0,
            'totalCost': 0.0,
            'totalDistance': 0.0,
            'avgConsumption': 0.0,
            'avgPricePerLiter': 0.0,
          };
          chartData = [];
        }

        if (yearExpenses.isNotEmpty) {
          expenseStats = await _databaseService.getExpenseStatistics(
            widget.car.carStatisticsTable,
            yearExpenses.length,
          );
        } else {
          expenseStats = {
            'count': 0,
            'totalCost': 0.0,
            'avgCost': 0.0,
            'categoryCosts': <int, double>{},
          };
        }
      }

      setState(() {
        _refuelStats = refuelStats;
        _expenseStats = expenseStats;
        _chartData = chartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.errorLoadingStatistics(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _onRangeChanged(int? newRange) async {
    if (newRange != null) {
      if (newRange == _yearPickerOption) {
        // Show year picker dialog
        await _showYearPicker();
      } else if (newRange != _selectedRange) {
        setState(() => _selectedRange = newRange);
        await _settingsService.setStatisticsRange(newRange);
        _loadStatistics();
      }
    }
  }

  Future<void> _showYearPicker() async {
    if (_availableYears.isEmpty) return;

    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableYears.length,
              itemBuilder: (context, index) {
                final year = _availableYears[index];
                return ListTile(
                  title: Text('$year'),
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );

    if (selectedYear != null) {
      final yearRange = -selectedYear;
      setState(() => _selectedRange = yearRange);
      await _settingsService.setStatisticsRange(yearRange);
      _updateRangeOptions(); // Update dropdown options to include selected year
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.statisticsTitle(widget.car.carAliasName ?? widget.car.carName),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Period selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dataRange,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedRange,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: l10n.dataRange,
                            ),
                            items: _rangeOptions.map((range) {
                              return DropdownMenuItem(
                                value: range,
                                child: Text(_getRangeLabel(range, l10n)),
                              );
                            }).toList(),
                            onChanged: _onRangeChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cost summary
                  _buildCostSummaryCard(l10n, currencyService),
                  const SizedBox(height: 16),

                  // Refuel statistics
                  _buildRefuelStatisticsCard(l10n, currencyService),
                  const SizedBox(height: 16),

                  // Expense statistics
                  _buildExpenseStatisticsCard(l10n, currencyService),
                  const SizedBox(height: 16),

                  // Charts
                  if (_chartData.isNotEmpty) ...[
                    _buildVolumeChart(l10n),
                    const SizedBox(height: 16),
                    _buildConsumptionChart(l10n),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCostSummaryCard(
    AppLocalizations l10n,
    CurrencyService currencyService,
  ) {
    final refuelTotalCost = _refuelStats['totalCost'] ?? 0.0;
    final expenseTotalCost = _expenseStats['totalCost'] ?? 0.0;
    final totalCost = refuelTotalCost + expenseTotalCost;
    final totalDistance = _refuelStats['totalDistance'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.fuel, style: const TextStyle(fontSize: 16)),
                Text(
                  currencyService.formatCurrency(refuelTotalCost),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.expenses, style: const TextStyle(fontSize: 16)),
                Text(
                  currencyService.formatCurrency(expenseTotalCost),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyService.formatCurrency(totalCost),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            if (totalDistance > 0) ...[
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.costPer100km,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currencyService.formatCurrency(
                      (totalCost / totalDistance) * 100,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRefuelStatisticsCard(
    AppLocalizations l10n,
    CurrencyService currencyService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.refuelStatistics,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            if (_refuelStats.isEmpty || _refuelStats['count'] == 0)
              Text(l10n.noDataToDisplay)
            else ...[
              _buildStatRow(l10n.numberOfRefuels, '${_refuelStats['count']}'),
              _buildStatRow(
                l10n.totalDistance,
                '${NumberFormat('#,##0', 'pl_PL').format(_refuelStats['totalDistance'])} km',
              ),
              _buildStatRow(
                l10n.totalFuelAmount,
                '${NumberFormat('#,##0.0', 'pl_PL').format(_refuelStats['totalVolume'])} l',
              ),
              _buildStatRow(
                l10n.totalCost,
                currencyService.formatCurrency(_refuelStats['totalCost']),
              ),
              _buildStatRow(
                l10n.averageConsumption,
                '${NumberFormat('#,##0.0', 'pl_PL').format(_refuelStats['avgConsumption'])} l/100km',
              ),
              _buildStatRow(
                l10n.averagePricePerLiter,
                currencyService.formatPricePerLiter(
                  _refuelStats['avgPricePerLiter'],
                ),
              ),
              if (_refuelStats['totalDistance'] > 0)
                _buildStatRow(
                  l10n.costPer100km,
                  currencyService.formatCurrency(
                    (_refuelStats['totalCost'] /
                            _refuelStats['totalDistance']) *
                        100,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseStatisticsCard(
    AppLocalizations l10n,
    CurrencyService currencyService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.expenseStatistics,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            if (_expenseStats.isEmpty || _expenseStats['count'] == 0)
              Text(l10n.noDataToDisplay)
            else ...[
              _buildStatRow(l10n.numberOfExpenses, '${_expenseStats['count']}'),
              _buildStatRow(
                l10n.totalCost,
                currencyService.formatCurrency(_expenseStats['totalCost']),
              ),
              _buildStatRow(
                l10n.averageCost,
                currencyService.formatCurrency(_expenseStats['avgCost']),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeChart(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.refuelChart,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}l');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _chartData.length) {
                            // Calculate interval: show ~10 labels for large datasets
                            final interval = _chartData.length > 10
                                ? (_chartData.length / 10).ceil()
                                : 1;
                            // Only show label if index is at interval or is first/last
                            if (index % interval == 0 ||
                                index == _chartData.length - 1) {
                              return Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _chartData.asMap().entries.map((entry) {
                    final isFullRefuel =
                        entry.value['refuelType'] == RefuelType.full.value;
                    // Calculate bar width: wider bars for fewer data points
                    // Range: 30px for <=5 items, down to 8px for >=50 items
                    final barWidth = (_chartData.length <= 5)
                        ? 32.0
                        : (_chartData.length <= 10)
                        ? 16.0
                        : (_chartData.length <= 20)
                        ? 8.0
                        : (_chartData.length <= 50)
                        ? 4.0
                        : 2.0;
                    return BarChartGroupData(
                      x: entry.key,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['volume'].toDouble(),
                          color: isFullRefuel ? Colors.orange : Colors.grey,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionChart(AppLocalizations l10n) {
    final consumptionData = _chartData
        .where(
          (data) => data['consumption'] != null && data['consumption'] <= 30.0,
        )
        .toList();

    if (consumptionData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.consumptionChart,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.noConsumptionData),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.consumptionChart,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toStringAsFixed(1)}l');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < consumptionData.length) {
                            // Calculate interval: show ~10 labels for large datasets
                            final interval = consumptionData.length > 10
                                ? (consumptionData.length / 10).ceil()
                                : 1;
                            // Only show label if index is at interval or is first/last
                            if (index % interval == 0 ||
                                index == consumptionData.length - 1) {
                              return Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: consumptionData.asMap().entries.map((entry) {
                    final isFullRefuel =
                        entry.value['refuelType'] == RefuelType.full.value;
                    // Calculate bar width: wider bars for fewer data points
                    // Range: 30px for <=5 items, down to 8px for >=50 items
                    final barWidth = (consumptionData.length <= 5)
                        ? 32.0
                        : (consumptionData.length <= 10)
                        ? 16.0
                        : (consumptionData.length <= 20)
                        ? 8.0
                        : (consumptionData.length <= 50)
                        ? 4.0
                        : 2.0;
                    return BarChartGroupData(
                      x: entry.key,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['consumption'].toDouble(),
                          color: isFullRefuel ? Colors.red : Colors.grey,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

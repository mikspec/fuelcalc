import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/car.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  final Car car;

  const StatisticsScreen({super.key, required this.car});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  int _selectedRange = 10; // Default: ostatnie 10
  Map<String, dynamic> _refuelStats = {};
  Map<String, dynamic> _expenseStats = {};
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  final List<int> _rangeOptions = [5, 10, 0]; // 0 oznacza wszystkie
  
  String _getRangeLabel(int range, AppLocalizations l10n) {
    switch (range) {
      case 5: return l10n.last5;
      case 10: return l10n.last10;
      case 0: return l10n.all;
      default: return '${l10n.last10} $range';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final count = _selectedRange == 0 ? 999999 : _selectedRange;
      
      final refuelStats = await _databaseService.getRefuelStatistics(widget.car.carName, count);
      final expenseStats = await _databaseService.getExpenseStatistics(widget.car.carStatisticsTable, count);
      final chartData = await _databaseService.getRefuelChartData(widget.car.carName, count);
      
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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingStatistics(e.toString()))),
        );
      }
    }
  }

  void _onRangeChanged(int? newRange) {
    if (newRange != null && newRange != _selectedRange) {
      setState(() => _selectedRange = newRange);
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle(widget.car.carAliasName ?? widget.car.carName)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Wybór zakresu
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dataRange,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedRange,
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
                  
                  // Podsumowanie kosztów
                  _buildCostSummaryCard(l10n),
                  const SizedBox(height: 16),
                  
                  // Statystyki tankowań
                  _buildRefuelStatisticsCard(l10n),
                  const SizedBox(height: 16),
                  
                  // Statystyki wydatków
                  _buildExpenseStatisticsCard(l10n),
                  const SizedBox(height: 16),
                  
                  // Wykresy
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

  Widget _buildCostSummaryCard(AppLocalizations l10n) {
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
                  NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(refuelTotalCost),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.expenses, style: const TextStyle(fontSize: 16)),
                Text(
                  NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(expenseTotalCost),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(totalCost),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),
            if (totalDistance > 0) ...[
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.costPer100km, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(
                    NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format((totalCost / totalDistance) * 100),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRefuelStatisticsCard(AppLocalizations l10n) {
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
              _buildStatRow(l10n.totalDistance, '${NumberFormat('#,##0', 'pl_PL').format(_refuelStats['totalDistance'])} km'),
              _buildStatRow(l10n.totalFuelAmount, '${NumberFormat('#,##0.0', 'pl_PL').format(_refuelStats['totalVolume'])} l'),
              _buildStatRow(l10n.totalCost, '${NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(_refuelStats['totalCost'])}'),
              _buildStatRow(l10n.averageConsumption, '${NumberFormat('#,##0.0', 'pl_PL').format(_refuelStats['avgConsumption'])} l/100km'),
              _buildStatRow(l10n.averagePricePerLiter, '${NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(_refuelStats['avgPricePerLiter'])}'),
              if (_refuelStats['totalDistance'] > 0)
                _buildStatRow(l10n.costPer100km, '${NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format((_refuelStats['totalCost'] / _refuelStats['totalDistance']) * 100)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseStatisticsCard(AppLocalizations l10n) {
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
              _buildStatRow(l10n.totalCost, '${NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(_expenseStats['totalCost'])}'),
              _buildStatRow(l10n.averageCost, '${NumberFormat.currency(locale: 'pl_PL', symbol: 'zł').format(_expenseStats['avgCost'])}'),
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
                            final date = DateTime.parse(_chartData[index]['date']);
                            return Text('${date.day}/${date.month}', style: TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _chartData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['volume'].toDouble(),
                          color: Colors.orange,
                          width: 16,
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
    final consumptionData = _chartData.where((data) => data['consumption'] != null).toList();
    
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
                            final date = DateTime.parse(consumptionData[index]['date']);
                            return Text('${date.day}/${date.month}', style: TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: consumptionData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['consumption'].toDouble(),
                          color: Colors.red,
                          width: 16,
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
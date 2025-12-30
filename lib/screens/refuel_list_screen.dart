import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/refuel_type.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../l10n/app_localizations.dart';
import 'refuel_form_screen.dart';
import 'refuel_map_screen.dart';

class RefuelListScreen extends StatefulWidget {
  final Car car;

  const RefuelListScreen({super.key, required this.car});

  @override
  State<RefuelListScreen> createState() => _RefuelListScreenState();
}

class _RefuelListScreenState extends State<RefuelListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final NumberFormat _numberFormat = NumberFormat('#,##0.0', 'pl_PL');

  List<Refuel> _refuels = [];
  List<double> _displayConsumptions = [];
  List<double> _calculatedOdometers = []; // Store calculated odometer readings
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefuels();
  }

  Future<void> _loadRefuels() async {
    setState(() => _isLoading = true);
    try {
      final refuels = await _databaseService.getRefuels(widget.car.carName);
      setState(() {
        _refuels = refuels;
        _displayConsumptions = _calculateDisplayConsumptions(refuels);
        _calculatedOdometers = _calculateOdometers(refuels);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingRefuels(e.toString()),
            ),
          ),
        );
      }
    }
  }

  List<double> _calculateDisplayConsumptions(List<Refuel> refuels) {
    if (refuels.isEmpty) return [];

    final consumptions = List<double>.filled(refuels.length, 0.0);
    double lastFullConsumption = 0.0;

    // Iterate from oldest to newest
    for (int i = refuels.length - 1; i >= 0; i--) {
      final refuel = refuels[i];

      if (refuel.refuelType == RefuelType.full) {
        // Full refuel - calculate consumption including preceding partial refuels
        double totalFuel = refuel.volumes;
        double totalDistance = refuel.distance;

        // Look for partial refuels between this full refuel and the previous full refuel
        for (int j = i + 1; j < refuels.length; j++) {
          final previousRefuel = refuels[j];
          if (previousRefuel.refuelType == RefuelType.full) {
            // Stop at the previous full refuel
            break;
          }
          // Add partial refuel's fuel and distance
          totalFuel += previousRefuel.volumes;
          totalDistance += previousRefuel.distance;
        }

        // Calculate consumption with accumulated values
        final calculatedConsumption = totalDistance > 0
            ? (totalFuel / totalDistance) * 100
            : 0.0;

        consumptions[i] = calculatedConsumption;
        lastFullConsumption = calculatedConsumption;
      } else {
        // Partial refuel - show consumption from the previous full refuel
        consumptions[i] = lastFullConsumption;
      }
    }

    return consumptions;
  }

  /// Calculate odometer readings based on car_initial_millage + sum of distances
  List<double> _calculateOdometers(List<Refuel> refuels) {
    if (refuels.isEmpty) return [];

    final odometers = <double>[];
    double cumulativeDistance = 0.0;

    // Iterate from oldest to newest (reverse order since refuels are newest first)
    for (int i = refuels.length - 1; i >= 0; i--) {
      cumulativeDistance += refuels[i].distance;
      final odometer = widget.car.carInitialMileage + cumulativeDistance;
      odometers.insert(0, odometer); // Insert at beginning to maintain order
    }

    return odometers;
  }

  void _addRefuel() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefuelFormScreen(car: widget.car),
      ),
    );
    if (result == true) {
      _loadRefuels();
    }
  }

  void _editRefuel(Refuel refuel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefuelFormScreen(car: widget.car, refuel: refuel),
      ),
    );
    if (result == true) {
      _loadRefuels();
    }
  }

  void _deleteRefuel(Refuel refuel) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRefuel),
        content: Text(
          l10n.deleteRefuelConfirm(
            DateFormat('dd.MM.yyyy').format(refuel.date),
          ),
        ),
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
        await _databaseService.deleteRefuel(widget.car.carName, refuel.id!);
        _loadRefuels();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.refuelDeleted),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.errorDeleteRefuel(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.refuelsTitle(widget.car.carAliasName ?? widget.car.carName),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RefuelMapScreen(car: widget.car),
                ),
              );
            },
            icon: const Icon(Icons.map),
            tooltip: l10n.refuelMap,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _refuels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_gas_station,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRefuelsYet,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addFirstRefuel,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRefuels,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _refuels.length,
                itemBuilder: (context, index) {
                  final l10n = AppLocalizations.of(context)!;
                  final refuel = _refuels[index];
                  return Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.local_gas_station,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${_numberFormat.format(refuel.volumes)} l • ${currencyService.formatPricePerLiter(refuel.prize)} • ${currencyService.formatCurrency(refuel.totalCost)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${DateFormat('dd.MM.yyyy HH:mm').format(refuel.date)} • ${refuel.refuelType == RefuelType.full ? l10n.fullTank : l10n.partial}',
                                ),
                              ),
                              if (refuel.gpsLatitude != 0.0 ||
                                  refuel.gpsLongitude != 0.0)
                                Tooltip(
                                  message: l10n.gpsLocation,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                          if (refuel.distance > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.route,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_numberFormat.format(refuel.distance)} km',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.speed,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_numberFormat.format(_displayConsumptions.elementAt(index))} l/100km',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _editRefuel(refuel);
                              break;
                            case 'delete':
                              _deleteRefuel(refuel);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit),
                                const SizedBox(width: 8),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete),
                                const SizedBox(width: 8),
                                Text(l10n.delete),
                              ],
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDetailItem(
                                    l10n.pricePerLiter,
                                    currencyService.formatPricePerLiter(
                                      refuel.prize,
                                    ),
                                    Icons.attach_money,
                                  ),
                                  if (refuel.distance > 0)
                                    _buildDetailItem(
                                      l10n.consumption,
                                      '${_numberFormat.format(_displayConsumptions.elementAt(index))} l/100km',
                                      Icons.speed,
                                    ),
                                  if (refuel.distance > 0)
                                    _buildDetailItem(
                                      l10n.distance,
                                      '${_numberFormat.format(refuel.distance)} km',
                                      Icons.route,
                                    ),
                                ],
                              ),
                              if (_calculatedOdometers.isNotEmpty &&
                                  _calculatedOdometers[index] > 0) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailItem(
                                      l10n.odometerReading,
                                      '${_numberFormat.format(_calculatedOdometers[index])} km',
                                      Icons.speed,
                                    ),
                                  ],
                                ),
                              ],
                              if (refuel.gpsLatitude != 0.0 ||
                                  refuel.gpsLongitude != 0.0) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailItem(
                                      l10n.gpsLocation,
                                      '${refuel.gpsLatitude.toStringAsFixed(4)}, ${refuel.gpsLongitude.toStringAsFixed(4)}',
                                      Icons.location_on,
                                    ),
                                  ],
                                ),
                              ],
                              if (refuel.information != null &&
                                  refuel.information!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    refuel.information!,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${l10n.rating} '),
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < refuel.rating
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addRefuel,
        tooltip: l10n.addRefuelTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

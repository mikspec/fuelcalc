import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/refuel_type.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../l10n/app_localizations.dart';

class RefuelMapScreen extends StatefulWidget {
  final Car car;

  const RefuelMapScreen({super.key, required this.car});

  @override
  State<RefuelMapScreen> createState() => _RefuelMapScreenState();
}

class _RefuelMapScreenState extends State<RefuelMapScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final MapController _mapController = MapController();
  final NumberFormat _numberFormat = NumberFormat('#,##0.0', 'pl_PL');

  List<Refuel> _refuels = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(52.2297, 21.0122); // Warsaw, Poland

  @override
  void initState() {
    super.initState();
    _loadRefuels();
  }

  Future<void> _loadRefuels() async {
    setState(() => _isLoading = true);
    try {
      final refuels = await _databaseService.getRefuels(widget.car.carName);

      // Filter refuels that have GPS coordinates
      final gpsRefuels = refuels
          .where(
            (refuel) =>
                refuel.gpsLatitude != null && refuel.gpsLongitude != null,
          )
          .toList();

      _createMarkers(gpsRefuels);

      // Calculate center position if we have GPS refuels
      if (gpsRefuels.isNotEmpty) {
        _calculateCenterPosition(gpsRefuels);
      }

      setState(() {
        _refuels = gpsRefuels;
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

  void _createMarkers(List<Refuel> refuels) {
    final markers = <Marker>[];

    for (int i = 0; i < refuels.length; i++) {
      final refuel = refuels[i];
      if (refuel.gpsLatitude == null || refuel.gpsLongitude == null) continue;

      final position = LatLng(refuel.gpsLatitude!, refuel.gpsLongitude!);

      markers.add(
        Marker(
          point: position,
          child: GestureDetector(
            onTap: () => _showRefuelDetails(refuel),
            child: Icon(
              Icons.local_gas_station,
              color: refuel.refuelType == RefuelType.full
                  ? Colors.green
                  : Colors.orange,
              size: 30,
            ),
          ),
        ),
      );
    }

    _markers = markers;
  }

  void _calculateCenterPosition(List<Refuel> refuels) {
    if (refuels.isEmpty) return;

    double minLat = refuels.first.gpsLatitude!;
    double maxLat = refuels.first.gpsLatitude!;
    double minLng = refuels.first.gpsLongitude!;
    double maxLng = refuels.first.gpsLongitude!;

    for (final refuel in refuels) {
      if (refuel.gpsLatitude == null || refuel.gpsLongitude == null) continue;

      minLat = minLat < refuel.gpsLatitude! ? minLat : refuel.gpsLatitude!;
      maxLat = maxLat > refuel.gpsLatitude! ? maxLat : refuel.gpsLatitude!;
      minLng = minLng < refuel.gpsLongitude! ? minLng : refuel.gpsLongitude!;
      maxLng = maxLng > refuel.gpsLongitude! ? maxLng : refuel.gpsLongitude!;
    }

    _initialPosition = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  void _showRefuelDetails(Refuel refuel) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${l10n.refuel} #${refuel.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                l10n.date,
                DateFormat('dd.MM.yyyy HH:mm').format(refuel.date),
              ),
              _buildDetailRow(
                l10n.volume,
                '${_numberFormat.format(refuel.volumes)} l',
              ),
              _buildDetailRow(
                l10n.totalCost,
                currencyService.formatCurrency(refuel.totalCost),
              ),
              _buildDetailRow(
                l10n.pricePerLiter,
                currencyService.formatPricePerLiter(refuel.prize),
              ),
              _buildDetailRow(
                l10n.refuelType,
                refuel.refuelType == RefuelType.full
                    ? l10n.fullTank
                    : l10n.partial,
              ),
              if (refuel.distance > 0)
                _buildDetailRow(
                  l10n.distance,
                  '${_numberFormat.format(refuel.distance)} km',
                ),
              if (refuel.distance > 0)
                _buildDetailRow(
                  l10n.consumption,
                  '${_numberFormat.format(refuel.consumption)} l/100km',
                ),
              _buildDetailRow(
                l10n.gpsLocation,
                (refuel.gpsLatitude != null && refuel.gpsLongitude != null)
                    ? '${refuel.gpsLatitude!.toStringAsFixed(6)}, ${refuel.gpsLongitude!.toStringAsFixed(6)}'
                    : l10n.locationUnavailable,
              ),
              if (refuel.information != null && refuel.information!.isNotEmpty)
                _buildDetailRow(l10n.notes, refuel.information!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _fitMarkersInView() {
    if (_refuels.isEmpty) return;

    double minLat = _refuels.first.gpsLatitude!;
    double maxLat = _refuels.first.gpsLatitude!;
    double minLng = _refuels.first.gpsLongitude!;
    double maxLng = _refuels.first.gpsLongitude!;

    for (final refuel in _refuels) {
      if (refuel.gpsLatitude == null || refuel.gpsLongitude == null) continue;

      minLat = minLat < refuel.gpsLatitude! ? minLat : refuel.gpsLatitude!;
      maxLat = maxLat > refuel.gpsLatitude! ? maxLat : refuel.gpsLatitude!;
      minLng = minLng < refuel.gpsLongitude! ? minLng : refuel.gpsLongitude!;
      maxLng = maxLng > refuel.gpsLongitude! ? maxLng : refuel.gpsLongitude!;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refuelMap),
        actions: [
          if (_refuels.isNotEmpty)
            IconButton(
              onPressed: _fitMarkersInView,
              icon: const Icon(Icons.center_focus_strong),
              tooltip: l10n.centerMap,
            ),
          IconButton(
            onPressed: _loadRefuels,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
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
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noGpsRefuels,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noGpsRefuelsDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.fuelcalc',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.legend,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_gas_station,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.fullTank,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_gas_station,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.partial,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${l10n.totalRefuels}: ${_refuels.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

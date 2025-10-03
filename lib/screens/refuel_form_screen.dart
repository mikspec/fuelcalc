import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/distance_calculator_service.dart';
import '../l10n/app_localizations.dart';

class RefuelFormScreen extends StatefulWidget {
  final Car car;
  final Refuel? refuel;

  const RefuelFormScreen({super.key, required this.car, this.refuel});

  @override
  State<RefuelFormScreen> createState() => _RefuelFormScreenState();
}

class _RefuelFormScreenState extends State<RefuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  late TextEditingController _volumesController;
  late TextEditingController _prizeController;
  late TextEditingController _odometerController;
  late TextEditingController _informationController;
  
  DateTime _selectedDate = DateTime.now();
  double _rating = 5.0;
  int _refuelType = 11; // 11 = Full tank (based on schema)
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  double _calculatedDistance = 0.0;
  double? _lastOdometerReading;
  double _gpsLatitude = 0.0;
  double _gpsLongitude = 0.0;
  bool get _isEditing => widget.refuel != null;

  @override
  void initState() {
    super.initState();
    final refuel = widget.refuel;
    _volumesController = TextEditingController(text: refuel?.volumes.toString() ?? '');
    _prizeController = TextEditingController(text: refuel?.prize.toString() ?? '');
    _odometerController = TextEditingController(text: refuel?.odometerState.toString() ?? '');
    _informationController = TextEditingController(text: refuel?.information ?? '');
    
    if (refuel != null) {
      _selectedDate = refuel.date;
      _rating = refuel.rating;
      _refuelType = refuel.refuelType;
      _calculatedDistance = refuel.distance;
      _gpsLatitude = refuel.gpsLatitude;
      _gpsLongitude = refuel.gpsLongitude;
    } else {
      _loadLastOdometerReading();
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _volumesController.dispose();
    _prizeController.dispose();
    _odometerController.dispose();
    _informationController.dispose();
    super.dispose();
  }

  Future<void> _loadLastOdometerReading() async {
    try {
      final refuels = await _databaseService.getRefuels(widget.car.carName, limit: 1);
      if (refuels.isNotEmpty) {
        setState(() {
          _lastOdometerReading = refuels.first.odometerState;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading last odometer reading: $e');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!LocationService.isLocationSupported) return;
    
    setState(() => _isLoadingLocation = true);
    
    try {
      final coordinates = await LocationService.getLocationCoordinates();
      setState(() {
        _gpsLatitude = coordinates['latitude']!;
        _gpsLongitude = coordinates['longitude']!;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (kDebugMode) {
        debugPrint('Error loading location: $e');
      }
    }
  }

  Future<void> _calculateDistance() async {
    final odometerText = _odometerController.text;
    if (odometerText.isEmpty) {
      setState(() => _calculatedDistance = 0.0);
      return;
    }

    final currentOdometer = double.tryParse(odometerText);
    if (currentOdometer == null || currentOdometer <= 0) {
      setState(() => _calculatedDistance = 0.0);
      return;
    }

    try {
      final distance = await DistanceCalculatorService.calculateDistance(
        widget.car.carName,
        currentOdometer,
      );
      setState(() => _calculatedDistance = distance);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calculating distance: $e');
      }
      setState(() => _calculatedDistance = 0.0);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveRefuel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // If it's a new refuel, get current location
      if (!_isEditing && LocationService.isLocationSupported) {
        final coordinates = await LocationService.getLocationCoordinates();
        _gpsLatitude = coordinates['latitude']!;
        _gpsLongitude = coordinates['longitude']!;
      }

      final refuel = Refuel(
        id: widget.refuel?.id,
        odometerState: double.tryParse(_odometerController.text) ?? 0.0,
        volumes: double.parse(_volumesController.text),
        prize: double.parse(_prizeController.text),
        information: _informationController.text.trim().isNotEmpty 
            ? _informationController.text.trim() 
            : null,
        rating: _rating,
        date: _selectedDate,
        distance: _calculatedDistance,
        gpsLatitude: _gpsLatitude,
        gpsLongitude: _gpsLongitude,
        refuelType: _refuelType,
      );

      if (_isEditing) {
        await _databaseService.updateRefuel(widget.car.carName, refuel);
      } else {
        await _databaseService.insertRefuel(widget.car.carName, refuel);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? AppLocalizations.of(context)!.refuelUpdated : AppLocalizations.of(context)!.refuelAdded),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSaving(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editRefuel : l10n.refuelForm),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveRefuel,
              child: Text(l10n.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.basicData,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _volumesController,
                            decoration: InputDecoration(
                              labelText: '${l10n.amount} *',
                              border: const OutlineInputBorder(),
                              suffixText: 'l',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              final volume = double.tryParse(value);
                              if (volume == null || volume <= 0) {
                                return l10n.invalidVolume;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _prizeController,
                            decoration: InputDecoration(
                              labelText: '${l10n.cost} *',
                              border: const OutlineInputBorder(),
                              suffixText: 'zł',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return l10n.invalidCost;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _odometerController,
                            decoration: InputDecoration(
                              labelText: '${l10n.odometer} *',
                              border: const OutlineInputBorder(),
                              suffixText: 'km',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => _calculateDistance(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              final odometer = double.tryParse(value);
                              if (odometer == null || odometer <= 0) {
                                return l10n.invalidOdometerReading;
                              }
                              
                              // Validate if odometer reading is greater than last
                              final validationMessage = DistanceCalculatorService
                                  .getOdometerValidationMessage(context, odometer, _lastOdometerReading);
                              return validationMessage;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.distanceFromLast,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.route,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DistanceCalculatorService.formatDistance(_calculatedDistance),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_lastOdometerReading != null && _lastOdometerReading! > 0)
                                  Text(
                                    l10n.lastOdometer(_lastOdometerReading!.toStringAsFixed(0)),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateAndDetails,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(l10n.date),
                            subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                            leading: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(l10n.time),
                            subtitle: Text(DateFormat('HH:mm').format(_selectedDate)),
                            leading: const Icon(Icons.access_time),
                            onTap: _selectTime,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.refuelType),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _refuelType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 11, child: Text(l10n.fullTank)),
                        DropdownMenuItem(value: 0, child: Text(l10n.partial)),
                      ],
                      onChanged: (value) => setState(() => _refuelType = value ?? 11),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.stationRating),
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _informationController,
                      decoration: InputDecoration(
                        labelText: l10n.notes,
                        border: const OutlineInputBorder(),
                        hintText: l10n.additionalInfoHint,
                      ),
                      maxLines: 3,
                    ),
                    if (LocationService.isLocationSupported) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: _isLoadingLocation ? Colors.grey : 
                                     (_gpsLatitude != 0.0 || _gpsLongitude != 0.0) ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isLoadingLocation 
                                  ? l10n.loadingLocation
                                  : (_gpsLatitude != 0.0 || _gpsLongitude != 0.0)
                                    ? l10n.locationCoordinates(_gpsLatitude.toStringAsFixed(6), _gpsLongitude.toStringAsFixed(6))
                                    : l10n.locationUnavailable,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            if (!_isLoadingLocation && (_gpsLatitude == 0.0 && _gpsLongitude == 0.0))
                              TextButton(
                                onPressed: _getCurrentLocation,
                                child: Text(l10n.getLocation, style: const TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _saveRefuel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? l10n.updateRefuel : l10n.addRefuelButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
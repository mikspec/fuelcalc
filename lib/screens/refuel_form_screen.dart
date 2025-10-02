import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/distance_calculator_service.dart';

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
      print('Błąd ładowania ostatniego odczytu licznika: $e');
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
      print('Błąd pobierania lokalizacji: $e');
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
      print('Błąd obliczania dystansu: $e');
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
      // Jeśli to nowe tankowanie, pobierz aktualną lokalizację
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
            content: Text(_isEditing ? 'Tankowanie zaktualizowane' : 'Tankowanie dodane'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd zapisu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edytuj tankowanie' : 'Dodaj tankowanie'),
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
              child: const Text('Zapisz'),
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
                    const Text(
                      'Podstawowe dane',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _volumesController,
                            decoration: const InputDecoration(
                              labelText: 'Ilość paliwa *',
                              border: OutlineInputBorder(),
                              suffixText: 'l',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wymagane';
                              }
                              final volume = double.tryParse(value);
                              if (volume == null || volume <= 0) {
                                return 'Nieprawidłowa ilość';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _prizeController,
                            decoration: const InputDecoration(
                              labelText: 'Koszt całkowity *',
                              border: OutlineInputBorder(),
                              suffixText: 'zł',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wymagane';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Nieprawidłowy koszt';
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
                            decoration: const InputDecoration(
                              labelText: 'Stan licznika *',
                              border: OutlineInputBorder(),
                              suffixText: 'km',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => _calculateDistance(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wymagane';
                              }
                              final odometer = double.tryParse(value);
                              if (odometer == null || odometer <= 0) {
                                return 'Nieprawidłowy stan';
                              }
                              
                              // Walidacja czy stan licznika jest większy od ostatniego
                              final validationMessage = DistanceCalculatorService
                                  .getOdometerValidationMessage(odometer, _lastOdometerReading);
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
                                const Text(
                                  'Dystans od ostatniego',
                                  style: TextStyle(
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
                                    'Ostatni: ${_lastOdometerReading!.toStringAsFixed(0)} km',
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
                    const Text(
                      'Data i szczegóły',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Data'),
                            subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                            leading: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Godzina'),
                            subtitle: Text(DateFormat('HH:mm').format(_selectedDate)),
                            leading: const Icon(Icons.access_time),
                            onTap: _selectTime,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Typ tankowania'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _refuelType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 11, child: Text('Pełny bak')),
                        DropdownMenuItem(value: 0, child: Text('Częściowe')),
                      ],
                      onChanged: (value) => setState(() => _refuelType = value ?? 11),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ocena stacji'),
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
                      decoration: const InputDecoration(
                        labelText: 'Notatki',
                        border: OutlineInputBorder(),
                        hintText: 'Dodatkowe informacje...',
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
                                  ? 'Pobieranie lokalizacji...'
                                  : (_gpsLatitude != 0.0 || _gpsLongitude != 0.0)
                                    ? 'Lokalizacja: ${_gpsLatitude.toStringAsFixed(6)}, ${_gpsLongitude.toStringAsFixed(6)}'
                                    : 'Lokalizacja niedostępna',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            if (!_isLoadingLocation && (_gpsLatitude == 0.0 && _gpsLongitude == 0.0))
                              TextButton(
                                onPressed: _getCurrentLocation,
                                child: const Text('Pobierz', style: TextStyle(fontSize: 12)),
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
                  _isEditing ? 'Zaktualizuj tankowanie' : 'Dodaj tankowanie',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
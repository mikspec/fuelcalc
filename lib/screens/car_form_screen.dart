import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/database_service.dart';

class CarFormScreen extends StatefulWidget {
  final Car? car;

  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  late TextEditingController _aliasNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _initialMileageController;
  late TextEditingController _relativeVolumeController;
  
  bool _isLoading = false;
  bool get _isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    _aliasNameController = TextEditingController(text: widget.car?.carAliasName ?? '');
    _descriptionController = TextEditingController(text: widget.car?.carDescription ?? '');
    _initialMileageController = TextEditingController(text: widget.car?.carInitialMileage.toString() ?? '0');
    _relativeVolumeController = TextEditingController(text: widget.car?.carRelativeVolume.toString() ?? '40.0');
  }

  @override
  void dispose() {
    _aliasNameController.dispose();
    _descriptionController.dispose();
    _initialMileageController.dispose();
    _relativeVolumeController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final car = Car(
        id: widget.car?.id,
        carName: widget.car?.carName ?? 'car_$timestamp',
        carDescription: _descriptionController.text.trim(),
        carAliasName: _aliasNameController.text.trim(),
        carAlgorithm: '1',
        carInitialMileage: int.tryParse(_initialMileageController.text) ?? 0,
        carTraveledDistance: widget.car?.carTraveledDistance ?? 0,
        carRelativeVolume: double.tryParse(_relativeVolumeController.text) ?? 40.0,
        carEnableRelativeVolume: 0,
        carChartPreferences: widget.car?.carChartPreferences,
        carStatisticsTable: widget.car?.carStatisticsTable ?? 'stats_$timestamp',
      );

      if (_isEditing) {
        await _databaseService.updateCar(car);
      } else {
        await _databaseService.insertCar(car);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Pojazd zaktualizowany' : 'Pojazd dodany'),
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
        title: Text(_isEditing ? 'Edytuj pojazd' : 'Dodaj pojazd'),
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
              onPressed: _saveCar,
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
                      'Podstawowe informacje',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aliasNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nazwa pojazdu *',
                        hintText: 'np. Honda Civic',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nazwa pojazdu jest wymagana';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Opis',
                        hintText: 'np. 1.6 VTEC, 2005r.',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
                      'Parametry techniczne',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _initialMileageController,
                      decoration: const InputDecoration(
                        labelText: 'Początkowy przebieg (km)',
                        border: OutlineInputBorder(),
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final mileage = int.tryParse(value);
                          if (mileage == null || mileage < 0) {
                            return 'Wprowadź prawidłowy przebieg';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relativeVolumeController,
                      decoration: const InputDecoration(
                        labelText: 'Pojemność baku (l)',
                        border: OutlineInputBorder(),
                        suffixText: 'l',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final volume = double.tryParse(value);
                          if (volume == null || volume <= 0) {
                            return 'Wprowadź prawidłową pojemność';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _saveCar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Zaktualizuj pojazd' : 'Dodaj pojazd',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
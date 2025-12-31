import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../services/database_service.dart';
import '../services/language_service.dart';
import '../services/currency_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';
import 'car_form_screen.dart';
import 'car_details_screen.dart';
import 'backup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SettingsService _settingsService = SettingsService();
  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    try {
      final cars = await _databaseService.getAllCars();
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingVehicles(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _addCar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarFormScreen()),
    );
    if (result == true) {
      _loadCars();
    }
  }

  void _editCar(Car car) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarFormScreen(car: car)),
    );
    if (result == true) {
      _loadCars();
    }
  }

  void _deleteCar(Car car) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVehicle),
        content: Text(
          l10n.deleteVehicleConfirm(car.carAliasName ?? car.carName),
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
        await _databaseService.deleteCar(car.id!);

        // Clear saved car if it's the one being deleted
        final savedCarId = await _settingsService.getChosenCarId();
        if (savedCarId == car.id) {
          await _settingsService.clearChosenCarId();
        }

        _loadCars();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.vehicleDeleted),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.errorDeleteVehicle(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  void _openCarDetails(Car car) async {
    // Save chosen car to settings
    await _settingsService.setChosenCarId(car.id!);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
      );
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageService languageService,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: RadioGroup<Locale>(
          groupValue: languageService.currentLocale,
          onChanged: (Locale? value) {
            if (value != null) {
              languageService.changeLanguage(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languageService.supportedLocales.map((locale) {
              return RadioListTile<Locale>(
                title: Text(
                  languageService.languageNames[locale.languageCode]!,
                ),
                value: locale,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCurrency),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: currencyService.currentCurrency,
            onChanged: (String? value) {
              if (value != null) {
                currencyService.changeCurrency(value);
                Navigator.pop(context);
              }
            },
            child: ListView(
              shrinkWrap: true,
              children: currencyService.availableCurrencies.map((currency) {
                final currencyInfo =
                    currencyService.supportedCurrencies[currency]!;
                return RadioListTile<String>(
                  title: Text(
                    '${currencyInfo['name']} (${currencyInfo['symbol']})',
                  ),
                  subtitle: Text(currencyInfo['code']!),
                  value: currency,
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final currencyService = Provider.of<CurrencyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'backup') {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => const BackupScreen()),
                );
                if (result == true) {
                  _loadCars();
                }
              } else if (value == 'language') {
                _showLanguageDialog(context, languageService);
              } else if (value == 'currency') {
                _showCurrencyDialog(context, currencyService);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    const Icon(Icons.backup),
                    const SizedBox(width: 8),
                    Text(l10n.backup),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'language',
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(l10n.language),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'currency',
                child: Row(
                  children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    Text(l10n.currency),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noVehicles,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final car = _cars[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(car.carAliasName ?? car.carName),
                    subtitle: Text(car.carDescription ?? l10n.noDescription),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editCar(car);
                            break;
                          case 'delete':
                            _deleteCar(car);
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
                    onTap: () => _openCarDetails(car),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCar,
        tooltip: l10n.addVehicle,
        child: const Icon(Icons.add),
      ),
    );
  }
}

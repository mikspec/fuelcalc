import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/car_details_screen.dart';
import 'services/language_service.dart';
import 'services/currency_service.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FuelCalcApp());
}

class FuelCalcApp extends StatelessWidget {
  const FuelCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageService()..init()),
        ChangeNotifierProvider(create: (context) => CurrencyService()..init()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Fuel Calculator',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: languageService.supportedLocales,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final SettingsService _settingsService = SettingsService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      final chosenCarId = await _settingsService.getChosenCarId();

      if (chosenCarId != null) {
        final car = await _databaseService.getCarById(chosenCarId);
        if (car != null) {
          setState(() {
            _initialScreen = CarDetailsScreen(car: car);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // If any error occurs, default to home screen
    }

    setState(() {
      _initialScreen = const HomeScreen();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _initialScreen!;
  }
}

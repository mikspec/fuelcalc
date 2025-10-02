import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const FuelCalcApp());
}

class FuelCalcApp extends StatelessWidget {
  const FuelCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageService()..init(),
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Fuel Calculator',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: languageService.supportedLocales,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

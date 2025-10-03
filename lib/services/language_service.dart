import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('pl'); // Default to Polish
  
  Locale get currentLocale => _currentLocale;
  
  List<Locale> get supportedLocales => const [
    Locale('pl'),
    Locale('en'),
  ];
  
  Map<String, String> get languageNames => const {
    'pl': 'Polski',
    'en': 'English',
  };
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
    } else {
      // Check system language
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (supportedLocales.any((locale) => locale.languageCode == systemLocale.languageCode)) {
        _currentLocale = Locale(systemLocale.languageCode);
      }
    }
    
    notifyListeners();
  }
  
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    
    notifyListeners();
  }
}
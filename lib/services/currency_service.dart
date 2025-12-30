import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CurrencyService extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';

  String _currentCurrency = 'PLN';
  String get currentCurrency => _currentCurrency;

  // Supported currencies with their display information
  final Map<String, Map<String, String>> supportedCurrencies = {
    'BGN': {
      'name': 'Bulgarian Lev',
      'symbol': 'лв',
      'code': 'BGN',
      'locale': 'bg_BG',
    },
    'CZK': {
      'name': 'Czech Koruna',
      'symbol': 'Kč',
      'code': 'CZK',
      'locale': 'cs_CZ',
    },
    'DKK': {
      'name': 'Danish Krone',
      'symbol': 'kr',
      'code': 'DKK',
      'locale': 'da_DK',
    },
    'EUR': {'name': 'Euro', 'symbol': '€', 'code': 'EUR', 'locale': 'en_EU'},
    'GBP': {
      'name': 'British Pound',
      'symbol': '£',
      'code': 'GBP',
      'locale': 'en_GB',
    },
    'HUF': {
      'name': 'Hungarian Forint',
      'symbol': 'Ft',
      'code': 'HUF',
      'locale': 'hu_HU',
    },
    'NOK': {
      'name': 'Norwegian Krone',
      'symbol': 'kr',
      'code': 'NOK',
      'locale': 'no_NO',
    },
    'PLN': {
      'name': 'Polish Złoty',
      'symbol': 'zł',
      'code': 'PLN',
      'locale': 'pl_PL',
    },
    'RON': {
      'name': 'Romanian Leu',
      'symbol': 'lei',
      'code': 'RON',
      'locale': 'ro_RO',
    },
    'SEK': {
      'name': 'Swedish Krona',
      'symbol': 'kr',
      'code': 'SEK',
      'locale': 'sv_SE',
    },
    'TRY': {
      'name': 'Turkish Lira',
      'symbol': '₺',
      'code': 'TRY',
      'locale': 'tr_TR',
    },
    'UAH': {
      'name': 'Ukrainian Hryvnia',
      'symbol': '₴',
      'code': 'UAH',
      'locale': 'uk_UA',
    },
    'USD': {
      'name': 'US Dollar',
      'symbol': '\$',
      'code': 'USD',
      'locale': 'en_US',
    },
  };

  String get currencySymbol =>
      supportedCurrencies[_currentCurrency]?['symbol'] ?? 'zł';
  String get currencyCode =>
      supportedCurrencies[_currentCurrency]?['code'] ?? 'PLN';
  String get currencyName =>
      supportedCurrencies[_currentCurrency]?['name'] ?? 'Polish Złoty';
  String get currencyLocale =>
      supportedCurrencies[_currentCurrency]?['locale'] ?? 'pl_PL';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString(_currencyKey) ?? 'PLN';
    notifyListeners();

    if (kDebugMode) {
      print('CurrencyService initialized with currency: $_currentCurrency');
    }
  }

  Future<void> changeCurrency(String currency) async {
    if (!supportedCurrencies.containsKey(currency)) {
      if (kDebugMode) {
        print('Unsupported currency: $currency');
      }
      return;
    }

    _currentCurrency = currency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);

    if (kDebugMode) {
      print('Currency changed to: $currency');
    }
  }

  List<String> get availableCurrencies => supportedCurrencies.keys.toList();

  // Format currency amount using appropriate formatter
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: currencyLocale,
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format price per liter with currency
  String formatPricePerLiter(double price) {
    final formatter = NumberFormat.currency(
      locale: currencyLocale,
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return '${formatter.format(price)}/l';
  }
}

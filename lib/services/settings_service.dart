import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsService {
  static const String _statisticsRangeKey = 'statistics_range';
  static const String _chosenCarIdKey = 'chosen_car_id';
  static const String _exchangeRatesKey = 'exchange_rates';
  static const String _lastUsedCurrencyKey = 'last_used_currency';
  static const int _defaultRange = 10;

  static SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get the statistics range setting (5, 10, or 0 for all)
  Future<int> getStatisticsRange() async {
    final prefs = await this.prefs;
    return prefs.getInt(_statisticsRangeKey) ?? _defaultRange;
  }

  /// Set the statistics range setting
  Future<void> setStatisticsRange(int range) async {
    final prefs = await this.prefs;
    await prefs.setInt(_statisticsRangeKey, range);
  }

  /// Get the chosen car ID
  Future<int?> getChosenCarId() async {
    final prefs = await this.prefs;
    return prefs.getInt(_chosenCarIdKey);
  }

  /// Set the chosen car ID
  Future<void> setChosenCarId(int carId) async {
    final prefs = await this.prefs;
    await prefs.setInt(_chosenCarIdKey, carId);
  }

  /// Clear the chosen car ID
  Future<void> clearChosenCarId() async {
    final prefs = await this.prefs;
    await prefs.remove(_chosenCarIdKey);
  }

  /// Get exchange rate for a currency pair (from -> to)
  /// Returns null if no rate is stored
  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    final prefs = await this.prefs;
    final ratesJson = prefs.getString(_exchangeRatesKey);

    if (ratesJson == null) return null;

    try {
      final rates = jsonDecode(ratesJson) as Map<String, dynamic>;
      final key = '${fromCurrency}_$toCurrency';
      final rate = rates[key];
      return rate != null ? (rate as num).toDouble() : null;
    } catch (e) {
      return null;
    }
  }

  /// Set exchange rate for a currency pair (from -> to)
  Future<void> setExchangeRate(
    String fromCurrency,
    String toCurrency,
    double rate,
  ) async {
    final prefs = await this.prefs;
    final ratesJson = prefs.getString(_exchangeRatesKey);

    Map<String, dynamic> rates = {};
    if (ratesJson != null) {
      try {
        rates = jsonDecode(ratesJson) as Map<String, dynamic>;
      } catch (e) {
        rates = {};
      }
    }

    final key = '${fromCurrency}_$toCurrency';
    rates[key] = rate;

    await prefs.setString(_exchangeRatesKey, jsonEncode(rates));
  }

  /// Get all stored exchange rates
  Future<Map<String, double>> getAllExchangeRates() async {
    final prefs = await this.prefs;
    final ratesJson = prefs.getString(_exchangeRatesKey);

    if (ratesJson == null) return {};

    try {
      final rates = jsonDecode(ratesJson) as Map<String, dynamic>;
      return rates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } catch (e) {
      return {};
    }
  }

  /// Get the last used currency for exchange
  Future<String?> getLastUsedCurrency() async {
    final prefs = await this.prefs;
    return prefs.getString(_lastUsedCurrencyKey);
  }

  /// Set the last used currency for exchange
  Future<void> setLastUsedCurrency(String currency) async {
    final prefs = await this.prefs;
    await prefs.setString(_lastUsedCurrencyKey, currency);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _statisticsRangeKey = 'statistics_range';
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
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';

class DistanceCalculatorService {
  static Future<double> calculateDistance(
    String carTableName, 
    double currentOdometer,
  ) async {
    try {
      final databaseService = DatabaseService();
      final refuels = await databaseService.getRefuels(carTableName, limit: 1);
      
      if (refuels.isEmpty || currentOdometer <= 0) {
        return 0.0;
      }
      
      final lastRefuel = refuels.first;
      final lastOdometer = lastRefuel.odometerState;
      
      if (lastOdometer <= 0 || currentOdometer <= lastOdometer) {
        return 0.0;
      }
      
      return currentOdometer - lastOdometer;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calculating distance: $e');
      }
      return 0.0;
    }
  }

  static String formatDistance(double distance) {
    if (distance <= 0) {
      return '0 km';
    }
    return '${distance.toStringAsFixed(0)} km';
  }

  static bool isValidOdometerReading(double currentOdometer, double? lastOdometer) {
    if (currentOdometer <= 0) return false;
    if (lastOdometer == null || lastOdometer <= 0) return true;
    return currentOdometer > lastOdometer;
  }

  static String? getOdometerValidationMessage(BuildContext context, double currentOdometer, double? lastOdometer) {
    final localizations = AppLocalizations.of(context)!;
    
    if (currentOdometer <= 0) {
      return localizations.odometerMustBeGreaterThanZero;
    }
    
    if (lastOdometer != null && lastOdometer > 0 && currentOdometer <= lastOdometer) {
      return localizations.odometerMustBeGreaterThanLast(lastOdometer.toStringAsFixed(0));
    }
    
    return null;
  }
}
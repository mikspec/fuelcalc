import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../models/car.dart';

class DistanceCalculatorService {
  /// Calculate distance based on car's initial mileage + sum of all previous distances
  static Future<double> calculateDistance(
    String carTableName,
    double currentOdometer,
    Car car,
  ) async {
    try {
      if (currentOdometer <= 0) {
        return 0.0;
      }

      final databaseService = DatabaseService();
      // Get all refuels to sum up distances
      final refuels = await databaseService.getRefuels(carTableName);

      // Calculate last odometer as: car_initial_millage + sum_of_all_distances
      double sumOfDistances = 0.0;
      for (var refuel in refuels) {
        sumOfDistances += refuel.distance;
      }

      final lastOdometer = car.carInitialMileage + sumOfDistances;

      if (currentOdometer <= lastOdometer) {
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

  /// Calculate the current odometer reading based on car's initial mileage and all refuel distances
  static Future<double> calculateCurrentOdometer(
    String carTableName,
    Car car,
  ) async {
    try {
      final databaseService = DatabaseService();
      final refuels = await databaseService.getRefuels(carTableName);

      double sumOfDistances = 0.0;
      for (var refuel in refuels) {
        sumOfDistances += refuel.distance;
      }

      return car.carInitialMileage + sumOfDistances;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calculating current odometer: $e');
      }
      return car.carInitialMileage.toDouble();
    }
  }

  static String formatDistance(double distance) {
    if (distance <= 0) {
      return '0 km';
    }
    return '${distance.toStringAsFixed(0)} km';
  }

  static bool isValidOdometerReading(
    double currentOdometer,
    double? lastOdometer,
  ) {
    if (currentOdometer <= 0) return false;
    if (lastOdometer == null || lastOdometer <= 0) return true;
    return currentOdometer > lastOdometer;
  }

  static String? getOdometerValidationMessage(
    BuildContext context,
    double currentOdometer,
    double? lastOdometer,
  ) {
    final localizations = AppLocalizations.of(context)!;

    if (currentOdometer <= 0) {
      return localizations.odometerMustBeGreaterThanZero;
    }

    if (lastOdometer != null &&
        lastOdometer > 0 &&
        currentOdometer <= lastOdometer) {
      return localizations.odometerMustBeGreaterThanLast(
        lastOdometer.toStringAsFixed(0),
      );
    }

    return null;
  }
}

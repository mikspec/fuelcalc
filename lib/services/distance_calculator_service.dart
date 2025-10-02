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
      print('Błąd obliczania dystansu: $e');
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

  static String? getOdometerValidationMessage(double currentOdometer, double? lastOdometer) {
    if (currentOdometer <= 0) {
      return 'Stan licznika musi być większy od 0';
    }
    
    if (lastOdometer != null && lastOdometer > 0 && currentOdometer <= lastOdometer) {
      return 'Stan licznika musi być większy od ostatniego odczytu (${lastOdometer.toStringAsFixed(0)} km)';
    }
    
    return null;
  }
}
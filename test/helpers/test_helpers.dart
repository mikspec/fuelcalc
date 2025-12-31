import 'package:fuelcalc/models/car.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';
import 'package:fuelcalc/models/expense.dart';

/// Test helper class providing factory methods for creating test data.
class TestHelpers {
  /// Creates a test car with default values.
  static Car createTestCar({
    int? id,
    String carName = 'test_car',
    String? carDescription,
    String? carAliasName = 'Test Car',
    String? carAlgorithm,
    int carInitialMileage = 50000,
    int carTraveledDistance = 0,
    double carRelativeVolume = 40.0,
    int carEnableRelativeVolume = 0,
    String? carChartPreferences,
    String carStatisticsTable = 'test_stats',
  }) {
    return Car(
      id: id,
      carName: carName,
      carDescription: carDescription,
      carAliasName: carAliasName,
      carAlgorithm: carAlgorithm,
      carInitialMileage: carInitialMileage,
      carTraveledDistance: carTraveledDistance,
      carRelativeVolume: carRelativeVolume,
      carEnableRelativeVolume: carEnableRelativeVolume,
      carChartPreferences: carChartPreferences,
      carStatisticsTable: carStatisticsTable,
    );
  }

  /// Creates a test refuel with default values.
  static Refuel createTestRefuel({
    int? id,
    double odometerState = 0.0,
    double volumes = 45.0,
    double prize = 6.50,
    String? information,
    double rating = 5.0,
    DateTime? date,
    double distance = 500.0,
    double? gpsLatitude,
    double? gpsLongitude,
    RefuelType refuelType = RefuelType.full,
  }) {
    return Refuel(
      id: id,
      odometerState: odometerState,
      volumes: volumes,
      prize: prize,
      information: information,
      rating: rating,
      date: date ?? DateTime.now(),
      distance: distance,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      refuelType: refuelType,
    );
  }

  /// Creates a test expense with default values.
  static Expense createTestExpense({
    int? id,
    DateTime? date,
    String? information,
    String statisticTitle = 'Test Expense',
    double statisticCost = 100.0,
    int statisticType = 0,
    int statisticSubtype = 0,
    double statisticRating = 5.0,
  }) {
    return Expense(
      id: id,
      date: date ?? DateTime.now(),
      information: information,
      statisticTitle: statisticTitle,
      statisticCost: statisticCost,
      statisticType: statisticType,
      statisticSubtype: statisticSubtype,
      statisticRating: statisticRating,
    );
  }

  /// Creates a list of test refuels for a given period.
  static List<Refuel> createRefuelSequence({
    int count = 5,
    DateTime? startDate,
    int daysBetween = 7,
    double avgVolume = 45.0,
    double avgDistance = 500.0,
    double avgPrice = 6.50,
  }) {
    final start = startDate ?? DateTime(2024, 1, 1);

    return List.generate(count, (index) {
      return Refuel(
        id: index + 1,
        volumes: avgVolume + (index % 3 - 1) * 5, // Vary volume slightly
        prize: avgPrice + (index % 2) * 0.30, // Vary price
        distance: avgDistance + (index % 4 - 2) * 20, // Vary distance
        date: start.add(Duration(days: index * daysBetween)),
        refuelType: index % 3 == 0 ? RefuelType.partial : RefuelType.full,
        information: 'Refuel ${index + 1}',
      );
    });
  }

  /// Creates a list of test expenses for different categories.
  static List<Expense> createExpensesByCategory() {
    final now = DateTime.now();

    return [
      createTestExpense(
        id: 1,
        date: now,
        statisticTitle: 'Car Wash',
        statisticCost: 50.0,
        statisticType: 0, // other
      ),
      createTestExpense(
        id: 2,
        date: now.subtract(const Duration(days: 30)),
        statisticTitle: 'Oil Change',
        statisticCost: 350.0,
        statisticType: 1, // maintenance
      ),
      createTestExpense(
        id: 3,
        date: now.subtract(const Duration(days: 60)),
        statisticTitle: 'Brake Pads',
        statisticCost: 800.0,
        statisticType: 2, // repair
      ),
      createTestExpense(
        id: 4,
        date: now.subtract(const Duration(days: 90)),
        statisticTitle: 'Tow Service',
        statisticCost: 400.0,
        statisticType: 3, // towing
      ),
      createTestExpense(
        id: 5,
        date: now.subtract(const Duration(days: 120)),
        statisticTitle: 'Annual Insurance',
        statisticCost: 2500.0,
        statisticType: 4, // insurance
      ),
      createTestExpense(
        id: 6,
        date: now.subtract(const Duration(days: 150)),
        statisticTitle: 'Technical Inspection',
        statisticCost: 150.0,
        statisticType: 5, // inspection
      ),
    ];
  }
}

/// Statistics calculation helper for tests.
class TestStatistics {
  /// Calculates average fuel consumption from a list of refuels.
  static double calculateAverageConsumption(List<Refuel> refuels) {
    if (refuels.isEmpty) return 0.0;

    final totalVolume = refuels.fold(0.0, (sum, r) => sum + r.volumes);
    final totalDistance = refuels.fold(0.0, (sum, r) => sum + r.distance);

    if (totalDistance == 0) return 0.0;
    return (totalVolume / totalDistance) * 100;
  }

  /// Calculates total fuel cost from a list of refuels.
  static double calculateTotalFuelCost(List<Refuel> refuels) {
    return refuels.fold(0.0, (sum, r) => sum + r.totalCost);
  }

  /// Calculates total distance from a list of refuels.
  static double calculateTotalDistance(List<Refuel> refuels) {
    return refuels.fold(0.0, (sum, r) => sum + r.distance);
  }

  /// Calculates total expense cost by category.
  static Map<int, double> calculateExpensesByCategory(List<Expense> expenses) {
    final result = <int, double>{};
    for (final expense in expenses) {
      result[expense.statisticType] =
          (result[expense.statisticType] ?? 0.0) + expense.statisticCost;
    }
    return result;
  }

  /// Calculates total expense cost.
  static double calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.statisticCost);
  }
}

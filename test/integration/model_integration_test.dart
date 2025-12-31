import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/car.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';
import 'package:fuelcalc/models/expense.dart';

/// Integration tests that validate interactions between different models
/// and simulate real-world usage scenarios.
void main() {
  group('Car with Refuels Integration Tests', () {
    late Car testCar;
    late List<Refuel> testRefuels;

    setUp(() {
      testCar = Car(
        id: 1,
        carName: 'car_1_123456',
        carAliasName: 'My VW Golf',
        carInitialMileage: 50000,
        carTraveledDistance: 0,
        carStatisticsTable: 'stats_1_123456',
      );

      testRefuels = [
        Refuel(
          id: 1,
          volumes: 45.0,
          prize: 6.50,
          distance: 520.0,
          date: DateTime(2024, 1, 10),
          refuelType: RefuelType.full,
          information: 'Shell station',
        ),
        Refuel(
          id: 2,
          volumes: 48.0,
          prize: 6.80,
          distance: 510.0,
          date: DateTime(2024, 1, 20),
          refuelType: RefuelType.full,
          information: 'BP station',
        ),
        Refuel(
          id: 3,
          volumes: 42.0,
          prize: 6.60,
          distance: 480.0,
          date: DateTime(2024, 1, 30),
          refuelType: RefuelType.full,
          information: 'Orlen station',
        ),
      ];
    });

    test('calculate total traveled distance from refuels', () {
      final totalDistance = testRefuels.fold(0.0, (sum, r) => sum + r.distance);

      // 520 + 510 + 480 = 1510 km
      expect(totalDistance, equals(1510.0));
    });

    test('calculate current odometer reading', () {
      final totalDistance = testRefuels.fold(0.0, (sum, r) => sum + r.distance);
      final currentOdometer = testCar.carInitialMileage + totalDistance;

      // 50000 + 1510 = 51510 km
      expect(currentOdometer, equals(51510.0));
    });

    test('calculate average consumption from refuels', () {
      final totalVolume = testRefuels.fold(0.0, (sum, r) => sum + r.volumes);
      final totalDistance = testRefuels.fold(0.0, (sum, r) => sum + r.distance);
      final avgConsumption = (totalVolume / totalDistance) * 100;

      // (45+48+42) / (520+510+480) * 100 = 135/1510*100 = 8.94 L/100km
      expect(avgConsumption, closeTo(8.94, 0.01));
    });

    test('calculate total fuel cost', () {
      final totalCost = testRefuels.fold(0.0, (sum, r) => sum + r.totalCost);

      // 45*6.50 + 48*6.80 + 42*6.60 = 292.50 + 326.40 + 277.20 = 896.10
      expect(totalCost, closeTo(896.10, 0.01));
    });

    test('calculate average price per liter', () {
      final totalVolume = testRefuels.fold(0.0, (sum, r) => sum + r.volumes);
      final totalCost = testRefuels.fold(0.0, (sum, r) => sum + r.totalCost);
      final avgPricePerLiter = totalCost / totalVolume;

      // 896.10 / 135 = 6.64 PLN/L
      expect(avgPricePerLiter, closeTo(6.64, 0.01));
    });

    test('sort refuels by date descending', () {
      final sortedRefuels = List<Refuel>.from(testRefuels)
        ..sort((a, b) => b.date.compareTo(a.date));

      expect(sortedRefuels[0].date.day, equals(30)); // Jan 30
      expect(sortedRefuels[1].date.day, equals(20)); // Jan 20
      expect(sortedRefuels[2].date.day, equals(10)); // Jan 10
    });

    test('filter refuels with GPS data', () {
      final refuelsWithGps = [
        Refuel(
          id: 1,
          volumes: 45.0,
          distance: 500.0,
          date: DateTime.now(),
          gpsLatitude: 52.2297,
          gpsLongitude: 21.0122,
        ),
        Refuel(
          id: 2,
          volumes: 40.0,
          distance: 450.0,
          date: DateTime.now(),
          // No GPS data
        ),
        Refuel(
          id: 3,
          volumes: 42.0,
          distance: 480.0,
          date: DateTime.now(),
          gpsLatitude: 50.0647,
          gpsLongitude: 19.9450,
        ),
      ];

      final withGps = refuelsWithGps
          .where((r) => r.gpsLatitude != null && r.gpsLongitude != null)
          .toList();

      expect(withGps.length, equals(2));
    });
  });

  group('Car with Expenses Integration Tests', () {
    late List<Expense> testExpenses;

    setUp(() {
      testExpenses = [
        Expense(
          id: 1,
          date: DateTime(2024, 1, 15),
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1, // maintenance
        ),
        Expense(
          id: 2,
          date: DateTime(2024, 2, 20),
          statisticTitle: 'Brake pads',
          statisticCost: 800.0,
          statisticType: 2, // repair
        ),
        Expense(
          id: 3,
          date: DateTime(2024, 3, 1),
          statisticTitle: 'Insurance',
          statisticCost: 2500.0,
          statisticType: 4, // insurance
        ),
        Expense(
          id: 4,
          date: DateTime(2024, 3, 15),
          statisticTitle: 'Car wash',
          statisticCost: 50.0,
          statisticType: 0, // other
        ),
      ];
    });

    test('calculate total expenses', () {
      final totalExpenses = testExpenses.fold(
        0.0,
        (sum, e) => sum + e.statisticCost,
      );

      // 350 + 800 + 2500 + 50 = 3700
      expect(totalExpenses, equals(3700.0));
    });

    test('group expenses by category', () {
      final categoryCosts = <int, double>{};
      for (final expense in testExpenses) {
        categoryCosts[expense.statisticType] =
            (categoryCosts[expense.statisticType] ?? 0.0) +
            expense.statisticCost;
      }

      expect(categoryCosts[0], equals(50.0)); // other
      expect(categoryCosts[1], equals(350.0)); // maintenance
      expect(categoryCosts[2], equals(800.0)); // repair
      expect(categoryCosts[4], equals(2500.0)); // insurance
    });

    test('find most expensive expense category', () {
      final categoryCosts = <int, double>{};
      for (final expense in testExpenses) {
        categoryCosts[expense.statisticType] =
            (categoryCosts[expense.statisticType] ?? 0.0) +
            expense.statisticCost;
      }

      final mostExpensiveCategory = categoryCosts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      expect(mostExpensiveCategory.key, equals(4)); // insurance
      expect(mostExpensiveCategory.value, equals(2500.0));
    });

    test('filter maintenance expenses', () {
      final maintenanceExpenses = testExpenses
          .where((e) => e.statisticType == 1)
          .toList();

      expect(maintenanceExpenses.length, equals(1));
      expect(maintenanceExpenses[0].statisticTitle, equals('Oil change'));
    });

    test('calculate monthly expense average', () {
      // Expenses span Jan-Mar (3 months)
      final totalExpenses = testExpenses.fold(
        0.0,
        (sum, e) => sum + e.statisticCost,
      );
      final monthlyAvg = totalExpenses / 3;

      // 3700 / 3 = 1233.33
      expect(monthlyAvg, closeTo(1233.33, 0.01));
    });
  });

  group('Complete Car Ownership Cost Analysis', () {
    test('calculate total cost of ownership', () {
      // Fuel costs
      final refuels = [
        Refuel(
          volumes: 45.0,
          prize: 6.50,
          distance: 500.0,
          date: DateTime(2024, 1, 15),
        ),
        Refuel(
          volumes: 48.0,
          prize: 6.80,
          distance: 520.0,
          date: DateTime(2024, 2, 15),
        ),
        Refuel(
          volumes: 42.0,
          prize: 6.60,
          distance: 480.0,
          date: DateTime(2024, 3, 15),
        ),
      ];

      final totalFuelCost = refuels.fold(0.0, (sum, r) => sum + r.totalCost);

      // Additional expenses
      final expenses = [
        Expense(
          date: DateTime(2024, 1, 20),
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1,
        ),
        Expense(
          date: DateTime(2024, 2, 1),
          statisticTitle: 'Insurance',
          statisticCost: 2500.0,
          statisticType: 4,
        ),
      ];

      final totalExpenseCost = expenses.fold(
        0.0,
        (sum, e) => sum + e.statisticCost,
      );

      final totalDistance = refuels.fold(0.0, (sum, r) => sum + r.distance);
      final totalCost = totalFuelCost + totalExpenseCost;

      // Total fuel: 45*6.50 + 48*6.80 + 42*6.60 = 896.10
      // Total expenses: 350 + 2500 = 2850
      // Total cost: 896.10 + 2850 = 3746.10
      expect(totalCost, closeTo(3746.10, 0.01));

      // Cost per km
      final costPerKm = totalCost / totalDistance;
      // 3746.10 / 1500 = 2.50 PLN/km
      expect(costPerKm, closeTo(2.50, 0.01));

      // Cost per 100km
      final costPer100km = (totalCost / totalDistance) * 100;
      expect(costPer100km, closeTo(249.74, 0.1));
    });
  });

  group('Partial Refuel Scenarios', () {
    test('calculate consumption with mixed refuel types', () {
      // Scenario: full -> partial -> partial -> full
      final refuels = [
        Refuel(
          id: 4,
          volumes: 40.0,
          distance: 420.0,
          date: DateTime(2024, 1, 25),
          refuelType: RefuelType.full,
        ),
        Refuel(
          id: 3,
          volumes: 15.0,
          distance: 180.0,
          date: DateTime(2024, 1, 18),
          refuelType: RefuelType.partial,
        ),
        Refuel(
          id: 2,
          volumes: 20.0,
          distance: 200.0,
          date: DateTime(2024, 1, 15),
          refuelType: RefuelType.partial,
        ),
        Refuel(
          id: 1,
          volumes: 45.0,
          distance: 500.0,
          date: DateTime(2024, 1, 10),
          refuelType: RefuelType.full,
        ),
      ];

      // Sort by date descending (newest first)
      refuels.sort((a, b) => b.date.compareTo(a.date));

      // Skip partial refuels at the beginning (newest)
      int startIndex = 0;
      while (startIndex < refuels.length &&
          refuels[startIndex].refuelType == RefuelType.partial) {
        startIndex++;
      }

      // First non-partial should be at index 0 (the full tank from Jan 25)
      expect(startIndex, equals(0));
      expect(refuels[startIndex].refuelType, equals(RefuelType.full));

      // Calculate total for accurate consumption:
      // Group partial refuels with their following full tank
      double totalVolume = 0;
      double totalDistance = 0;

      for (int i = startIndex; i < refuels.length; i++) {
        totalVolume += refuels[i].volumes;
        totalDistance += refuels[i].distance;
      }

      // 40 + 15 + 20 + 45 = 120 liters
      // 420 + 180 + 200 + 500 = 1300 km
      expect(totalVolume, equals(120.0));
      expect(totalDistance, equals(1300.0));

      final avgConsumption = (totalVolume / totalDistance) * 100;
      // 120 / 1300 * 100 = 9.23 L/100km
      expect(avgConsumption, closeTo(9.23, 0.01));
    });

    test('handle all partial refuels scenario', () {
      final refuels = [
        Refuel(
          volumes: 20.0,
          distance: 200.0,
          date: DateTime(2024, 1, 25),
          refuelType: RefuelType.partial,
        ),
        Refuel(
          volumes: 15.0,
          distance: 180.0,
          date: DateTime(2024, 1, 18),
          refuelType: RefuelType.partial,
        ),
        Refuel(
          volumes: 25.0,
          distance: 250.0,
          date: DateTime(2024, 1, 10),
          refuelType: RefuelType.partial,
        ),
      ];

      // All partial - cannot calculate accurate consumption
      final allPartial = refuels.every(
        (r) => r.refuelType == RefuelType.partial,
      );
      expect(allPartial, isTrue);

      // In this case, consumption calculation should return 0 or be skipped
      int startIndex = 0;
      while (startIndex < refuels.length &&
          refuels[startIndex].refuelType == RefuelType.partial) {
        startIndex++;
      }

      expect(startIndex, equals(refuels.length)); // All skipped
    });
  });

  group('Data Serialization Integration', () {
    test('car with refuels roundtrip', () {
      final car = Car(
        id: 1,
        carName: 'car_1',
        carAliasName: 'Test Car',
        carInitialMileage: 100000,
        carStatisticsTable: 'stats_1',
      );

      final refuel = Refuel(
        id: 1,
        volumes: 45.0,
        prize: 6.50,
        distance: 500.0,
        date: DateTime(2024, 1, 15, 10, 30, 0),
        refuelType: RefuelType.full,
        gpsLatitude: 52.2297,
        gpsLongitude: 21.0122,
      );

      // Simulate database storage and retrieval
      final carMap = car.toMap();
      final refuelMap = refuel.toMap();

      final restoredCar = Car.fromMap(carMap);
      final restoredRefuel = Refuel.fromMap(refuelMap);

      // Verify car
      expect(restoredCar.id, equals(car.id));
      expect(restoredCar.carAliasName, equals(car.carAliasName));
      expect(restoredCar.carInitialMileage, equals(car.carInitialMileage));

      // Verify refuel
      expect(restoredRefuel.volumes, equals(refuel.volumes));
      expect(restoredRefuel.consumption, equals(refuel.consumption));
      expect(restoredRefuel.totalCost, equals(refuel.totalCost));
      expect(restoredRefuel.gpsLatitude, equals(refuel.gpsLatitude));
    });

    test('expense categories roundtrip', () {
      // Test all expense types
      for (int typeId = 0; typeId <= 5; typeId++) {
        final expense = Expense(
          id: typeId + 1,
          date: DateTime(2024, 1, 15, 10, 0, 0),
          statisticTitle: 'Test ${Expense.expenseTypes[typeId]}',
          statisticCost: 100.0 * (typeId + 1),
          statisticType: typeId,
        );

        final map = expense.toMap();
        final restored = Expense.fromMap(map);

        expect(restored.statisticType, equals(typeId));
        expect(restored.typeKey, equals(Expense.expenseTypes[typeId]));
      }
    });
  });
}

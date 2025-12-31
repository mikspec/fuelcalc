import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';
import 'package:fuelcalc/models/refuel_type.dart';

/// Tests for test helper classes to ensure they work correctly.
void main() {
  group('TestHelpers Tests', () {
    group('createTestCar', () {
      test('creates car with default values', () {
        final car = TestHelpers.createTestCar();

        expect(car.id, isNull);
        expect(car.carName, equals('test_car'));
        expect(car.carAliasName, equals('Test Car'));
        expect(car.carInitialMileage, equals(50000));
        expect(car.carStatisticsTable, equals('test_stats'));
      });

      test('creates car with custom values', () {
        final car = TestHelpers.createTestCar(
          id: 1,
          carName: 'custom_car',
          carAliasName: 'My Custom Car',
          carInitialMileage: 100000,
        );

        expect(car.id, equals(1));
        expect(car.carName, equals('custom_car'));
        expect(car.carAliasName, equals('My Custom Car'));
        expect(car.carInitialMileage, equals(100000));
      });
    });

    group('createTestRefuel', () {
      test('creates refuel with default values', () {
        final refuel = TestHelpers.createTestRefuel();

        expect(refuel.id, isNull);
        expect(refuel.volumes, equals(45.0));
        expect(refuel.prize, equals(6.50));
        expect(refuel.distance, equals(500.0));
        expect(refuel.refuelType, equals(RefuelType.full));
      });

      test('creates refuel with custom values', () {
        final date = DateTime(2024, 6, 15);
        final refuel = TestHelpers.createTestRefuel(
          id: 1,
          volumes: 50.0,
          prize: 7.0,
          distance: 600.0,
          date: date,
          refuelType: RefuelType.partial,
        );

        expect(refuel.id, equals(1));
        expect(refuel.volumes, equals(50.0));
        expect(refuel.prize, equals(7.0));
        expect(refuel.distance, equals(600.0));
        expect(refuel.date, equals(date));
        expect(refuel.refuelType, equals(RefuelType.partial));
      });
    });

    group('createTestExpense', () {
      test('creates expense with default values', () {
        final expense = TestHelpers.createTestExpense();

        expect(expense.id, isNull);
        expect(expense.statisticTitle, equals('Test Expense'));
        expect(expense.statisticCost, equals(100.0));
        expect(expense.statisticType, equals(0));
      });

      test('creates expense with custom values', () {
        final expense = TestHelpers.createTestExpense(
          id: 1,
          statisticTitle: 'Oil Change',
          statisticCost: 350.0,
          statisticType: 1,
        );

        expect(expense.id, equals(1));
        expect(expense.statisticTitle, equals('Oil Change'));
        expect(expense.statisticCost, equals(350.0));
        expect(expense.statisticType, equals(1));
      });
    });

    group('createRefuelSequence', () {
      test('creates correct number of refuels', () {
        final refuels = TestHelpers.createRefuelSequence(count: 10);

        expect(refuels.length, equals(10));
      });

      test('refuels have sequential IDs', () {
        final refuels = TestHelpers.createRefuelSequence(count: 5);

        for (int i = 0; i < 5; i++) {
          expect(refuels[i].id, equals(i + 1));
        }
      });

      test('refuels have incrementing dates', () {
        final startDate = DateTime(2024, 1, 1);
        final refuels = TestHelpers.createRefuelSequence(
          count: 3,
          startDate: startDate,
          daysBetween: 7,
        );

        expect(refuels[0].date, equals(startDate));
        expect(refuels[1].date, equals(startDate.add(const Duration(days: 7))));
        expect(
          refuels[2].date,
          equals(startDate.add(const Duration(days: 14))),
        );
      });
    });

    group('createExpensesByCategory', () {
      test('creates expenses for all categories', () {
        final expenses = TestHelpers.createExpensesByCategory();

        expect(expenses.length, equals(6));

        // Check each category is represented
        final types = expenses.map((e) => e.statisticType).toSet();
        expect(types, containsAll([0, 1, 2, 3, 4, 5]));
      });
    });
  });

  group('TestStatistics Tests', () {
    group('calculateAverageConsumption', () {
      test('calculates correct average consumption', () {
        final refuels = [
          TestHelpers.createTestRefuel(volumes: 50.0, distance: 500.0),
          TestHelpers.createTestRefuel(volumes: 40.0, distance: 400.0),
        ];

        final avg = TestStatistics.calculateAverageConsumption(refuels);

        // (50+40) / (500+400) * 100 = 90/900*100 = 10 L/100km
        expect(avg, equals(10.0));
      });

      test('returns 0 for empty list', () {
        final avg = TestStatistics.calculateAverageConsumption([]);

        expect(avg, equals(0.0));
      });

      test('returns 0 for zero distance', () {
        final refuels = [
          TestHelpers.createTestRefuel(volumes: 50.0, distance: 0.0),
        ];

        final avg = TestStatistics.calculateAverageConsumption(refuels);

        expect(avg, equals(0.0));
      });
    });

    group('calculateTotalFuelCost', () {
      test('calculates correct total cost', () {
        final refuels = [
          TestHelpers.createTestRefuel(volumes: 40.0, prize: 6.0), // 240
          TestHelpers.createTestRefuel(volumes: 50.0, prize: 7.0), // 350
        ];

        final total = TestStatistics.calculateTotalFuelCost(refuels);

        expect(total, equals(590.0));
      });
    });

    group('calculateTotalDistance', () {
      test('calculates correct total distance', () {
        final refuels = [
          TestHelpers.createTestRefuel(distance: 500.0),
          TestHelpers.createTestRefuel(distance: 600.0),
          TestHelpers.createTestRefuel(distance: 450.0),
        ];

        final total = TestStatistics.calculateTotalDistance(refuels);

        expect(total, equals(1550.0));
      });
    });

    group('calculateExpensesByCategory', () {
      test('groups expenses by category correctly', () {
        final expenses = [
          TestHelpers.createTestExpense(statisticCost: 100.0, statisticType: 1),
          TestHelpers.createTestExpense(statisticCost: 200.0, statisticType: 1),
          TestHelpers.createTestExpense(statisticCost: 300.0, statisticType: 2),
        ];

        final byCategory = TestStatistics.calculateExpensesByCategory(expenses);

        expect(byCategory[1], equals(300.0)); // 100 + 200
        expect(byCategory[2], equals(300.0));
      });
    });

    group('calculateTotalExpenses', () {
      test('calculates correct total expenses', () {
        final expenses = [
          TestHelpers.createTestExpense(statisticCost: 100.0),
          TestHelpers.createTestExpense(statisticCost: 250.0),
          TestHelpers.createTestExpense(statisticCost: 150.0),
        ];

        final total = TestStatistics.calculateTotalExpenses(expenses);

        expect(total, equals(500.0));
      });
    });
  });
}

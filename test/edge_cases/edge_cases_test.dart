import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/car.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';
import 'package:fuelcalc/models/expense.dart';

/// Tests for edge cases and boundary conditions in the application.
void main() {
  group('Edge Case Tests', () {
    group('Car Edge Cases', () {
      test('car with very long names', () {
        final longName = 'A' * 1000; // Very long name
        final car = Car(
          carName: longName,
          carAliasName: longName,
          carDescription: longName,
          carStatisticsTable: 'stats_table',
        );

        expect(car.carName.length, equals(1000));

        // Should survive roundtrip
        final map = car.toMap();
        final restored = Car.fromMap(map);
        expect(restored.carName, equals(longName));
      });

      test('car with special characters in names', () {
        final car = Car(
          carName: 'car_with_special_chars',
          carAliasName: 'Škoda Fabia ąęółżźń',
          carDescription: '© 2024 - Special <>&"\'',
          carStatisticsTable: 'stats_1',
        );

        final map = car.toMap();
        final restored = Car.fromMap(map);

        expect(restored.carAliasName, equals('Škoda Fabia ąęółżźń'));
        expect(restored.carDescription, equals('© 2024 - Special <>&"\''));
      });

      test('car with maximum mileage', () {
        final car = Car(
          carName: 'high_mileage_car',
          carInitialMileage: 999999999,
          carStatisticsTable: 'stats_1',
        );

        expect(car.carInitialMileage, equals(999999999));
      });

      test('car with zero mileage', () {
        final car = Car(
          carName: 'new_car',
          carInitialMileage: 0,
          carStatisticsTable: 'stats_1',
        );

        expect(car.carInitialMileage, equals(0));
      });

      test('car with empty optional fields', () {
        final car = Car(
          carName: 'minimal_car',
          carDescription: '',
          carAliasName: '',
          carStatisticsTable: 'stats_1',
        );

        final map = car.toMap();
        final restored = Car.fromMap(map);

        expect(restored.carDescription, equals(''));
        expect(restored.carAliasName, equals(''));
      });
    });

    group('Refuel Edge Cases', () {
      test('refuel with very small volume', () {
        final refuel = Refuel(
          volumes: 0.01, // Very small amount
          distance: 1.0,
          date: DateTime.now(),
        );

        expect(refuel.consumption, equals(1.0)); // 0.01/1*100 = 1 L/100km
      });

      test('refuel with very large volume', () {
        final refuel = Refuel(
          volumes: 200.0, // Large truck tank
          distance: 1000.0,
          date: DateTime.now(),
        );

        expect(refuel.consumption, equals(20.0));
        expect(refuel.totalCost, equals(200.0 * 4.0)); // default prize
      });

      test('refuel with very long distance', () {
        final refuel = Refuel(
          volumes: 100.0,
          distance: 99999.0,
          date: DateTime.now(),
        );

        // 100/99999*100 = 0.1000... L/100km
        expect(refuel.consumption, closeTo(0.1, 0.01));
      });

      test('refuel with extreme GPS coordinates', () {
        // North Pole
        final northPole = Refuel(
          date: DateTime.now(),
          gpsLatitude: 90.0,
          gpsLongitude: 0.0,
        );
        expect(northPole.gpsLatitude, equals(90.0));

        // South Pole
        final southPole = Refuel(
          date: DateTime.now(),
          gpsLatitude: -90.0,
          gpsLongitude: 0.0,
        );
        expect(southPole.gpsLatitude, equals(-90.0));

        // International Date Line
        final dateLine = Refuel(
          date: DateTime.now(),
          gpsLatitude: 0.0,
          gpsLongitude: 180.0,
        );
        expect(dateLine.gpsLongitude, equals(180.0));
      });

      test('refuel with midnight date', () {
        final midnight = DateTime(2024, 1, 1, 0, 0, 0);
        final refuel = Refuel(date: midnight);

        final map = refuel.toMap();
        final restored = Refuel.fromMap(map);

        expect(restored.date.hour, equals(0));
        expect(restored.date.minute, equals(0));
      });

      test('refuel with end of day date', () {
        final endOfDay = DateTime(2024, 1, 1, 23, 59, 59);
        final refuel = Refuel(date: endOfDay);

        final map = refuel.toMap();
        final restored = Refuel.fromMap(map);

        expect(restored.date.hour, equals(23));
        expect(restored.date.minute, equals(59));
      });

      test('refuel with very high price', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 99.99, // Extremely high fuel price
          distance: 500.0,
          date: DateTime.now(),
        );

        expect(refuel.totalCost, closeTo(4999.5, 0.01));
        expect(refuel.costPer100km, closeTo(999.9, 0.01));
      });

      test('refuel with zero price (free fuel)', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 0.0,
          distance: 500.0,
          date: DateTime.now(),
        );

        expect(refuel.totalCost, equals(0.0));
        expect(refuel.costPer100km, equals(0.0));
      });
    });

    group('Expense Edge Cases', () {
      test('expense with very large cost', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Major Engine Rebuild',
          statisticCost: 999999.99,
          statisticType: 2,
        );

        expect(expense.statisticCost, equals(999999.99));
      });

      test('expense with zero cost', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Free Service',
          statisticCost: 0.0,
          statisticType: 1,
        );

        expect(expense.statisticCost, equals(0.0));
      });

      test('expense with very long title', () {
        final longTitle = 'A' * 500;
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: longTitle,
        );

        final map = expense.toMap();
        final restored = Expense.fromMap(map);

        expect(restored.statisticTitle.length, equals(500));
      });

      test('expense with unicode characters in title', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: '🚗 Naprawa silnika 🔧',
          information: 'Wymiana części: złączki, śruby, uszczelki',
        );

        final map = expense.toMap();
        final restored = Expense.fromMap(map);

        expect(restored.statisticTitle, contains('🚗'));
        expect(restored.information, contains('złączki'));
      });

      test('expense with minimum rating', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Bad Service',
          statisticRating: 0.0,
        );

        expect(expense.statisticRating, equals(0.0));
      });

      test('expense with maximum rating', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Excellent Service',
          statisticRating: 10.0,
        );

        expect(expense.statisticRating, equals(10.0));
      });
    });

    group('RefuelType Edge Cases', () {
      test('fromValue with boundary values', () {
        expect(RefuelType.fromValue(-1), equals(RefuelType.partial));
        expect(RefuelType.fromValue(0), equals(RefuelType.partial));
        expect(RefuelType.fromValue(10), equals(RefuelType.partial));
        expect(RefuelType.fromValue(11), equals(RefuelType.full));
        expect(RefuelType.fromValue(12), equals(RefuelType.partial));
        expect(RefuelType.fromValue(100), equals(RefuelType.partial));
      });
    });

    group('Date Parsing Edge Cases', () {
      test('refuel with leap year date', () {
        final leapYearDate = DateTime(2024, 2, 29); // 2024 is leap year
        final refuel = Refuel(date: leapYearDate);

        final map = refuel.toMap();
        final restored = Refuel.fromMap(map);

        expect(restored.date.month, equals(2));
        expect(restored.date.day, equals(29));
      });

      test('expense with end of year date', () {
        final endOfYear = DateTime(2024, 12, 31, 23, 59, 59);
        final expense = Expense(
          date: endOfYear,
          statisticTitle: 'Year End Service',
        );

        final map = expense.toMap();
        final restored = Expense.fromMap(map);

        expect(restored.date.month, equals(12));
        expect(restored.date.day, equals(31));
      });
    });

    group('Calculation Precision', () {
      test('consumption calculation precision', () {
        // Test for floating point precision issues
        final refuel = Refuel(
          volumes: 33.333,
          distance: 333.33,
          date: DateTime.now(),
        );

        // 33.333 / 333.33 * 100 ≈ 10.0
        expect(refuel.consumption, closeTo(10.0, 0.01));
      });

      test('cost calculation precision', () {
        final refuel = Refuel(
          volumes: 47.123,
          prize: 6.789,
          distance: 500.0,
          date: DateTime.now(),
        );

        // 47.123 * 6.789 = 319.98...
        expect(refuel.totalCost, closeTo(319.98, 0.1));
      });
    });
  });
}

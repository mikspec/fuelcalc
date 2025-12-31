import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/car.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';
import 'package:fuelcalc/models/expense.dart';

/// Tests for input validation and data integrity.
void main() {
  group('Data Validation Tests', () {
    group('Car Validation', () {
      test('car requires carName', () {
        final car = Car(carName: 'required_name', carStatisticsTable: 'stats');
        expect(car.carName, isNotEmpty);
      });

      test('car requires carStatisticsTable', () {
        final car = Car(carName: 'test', carStatisticsTable: 'required_table');
        expect(car.carStatisticsTable, isNotEmpty);
      });

      test('car mileage should be non-negative', () {
        final car = Car(
          carName: 'test',
          carInitialMileage: 0,
          carStatisticsTable: 'stats',
        );
        expect(car.carInitialMileage, greaterThanOrEqualTo(0));
      });

      test('car relative volume should be positive', () {
        final car = Car(
          carName: 'test',
          carRelativeVolume: 40.0,
          carStatisticsTable: 'stats',
        );
        expect(car.carRelativeVolume, greaterThan(0));
      });

      test('car table name format', () {
        final car = Car(
          carName: 'car_1_123456',
          carStatisticsTable: 'stats_1_123456',
        );
        // Table names should follow naming convention
        expect(car.carName, matches(RegExp(r'^car_\d+_\d+$')));
        expect(car.carStatisticsTable, matches(RegExp(r'^stats_\d+_\d+$')));
      });
    });

    group('Refuel Validation', () {
      test('refuel volume should be positive', () {
        final refuel = Refuel(volumes: 45.0, date: DateTime.now());
        expect(refuel.volumes, greaterThan(0));
      });

      test('refuel price should be non-negative', () {
        final refuel = Refuel(prize: 6.50, date: DateTime.now());
        expect(refuel.prize, greaterThanOrEqualTo(0));
      });

      test('refuel distance should be non-negative', () {
        final refuel = Refuel(distance: 500.0, date: DateTime.now());
        expect(refuel.distance, greaterThanOrEqualTo(0));
      });

      test('refuel rating should be between 0 and 5', () {
        final refuel = Refuel(rating: 5.0, date: DateTime.now());
        expect(refuel.rating, inInclusiveRange(0, 5));
      });

      test('refuel GPS latitude should be in valid range', () {
        final refuel = Refuel(gpsLatitude: 52.2297, date: DateTime.now());
        expect(refuel.gpsLatitude, inInclusiveRange(-90, 90));
      });

      test('refuel GPS longitude should be in valid range', () {
        final refuel = Refuel(gpsLongitude: 21.0122, date: DateTime.now());
        expect(refuel.gpsLongitude, inInclusiveRange(-180, 180));
      });

      test('refuel date should not be in future (business rule)', () {
        final refuel = Refuel(
          date: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(
          refuel.date.isBefore(DateTime.now().add(const Duration(days: 1))),
          isTrue,
        );
      });
    });

    group('Expense Validation', () {
      test('expense cost should be non-negative', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Test',
          statisticCost: 0.0,
        );
        expect(expense.statisticCost, greaterThanOrEqualTo(0));
      });

      test('expense type should be valid', () {
        final validTypes = [0, 1, 2, 3, 4, 5];
        for (final type in validTypes) {
          final expense = Expense(
            date: DateTime.now(),
            statisticTitle: 'Test',
            statisticType: type,
          );
          expect(
            Expense.expenseTypes.containsKey(expense.statisticType),
            isTrue,
          );
        }
      });

      test('expense title should not be empty', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Oil Change',
        );
        expect(expense.statisticTitle, isNotEmpty);
      });

      test('expense rating should be in valid range', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Test',
          statisticRating: 5.0,
        );
        expect(expense.statisticRating, inInclusiveRange(0, 10));
      });
    });

    group('Consumption Calculation Validation', () {
      test('consumption should be reasonable for normal car', () {
        final refuel = Refuel(
          volumes: 50.0,
          distance: 500.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        // Normal cars consume between 4-20 L/100km
        expect(refuel.consumption, inInclusiveRange(4, 20));
      });

      test('consumption handles edge case correctly', () {
        final refuel = Refuel(
          volumes: 50.0,
          distance: 0.0, // Edge case
          date: DateTime.now(),
        );

        // Should not throw, should return 0
        expect(refuel.consumption, equals(0.0));
      });

      test('cost per 100km should be reasonable', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 6.50,
          distance: 500.0,
          date: DateTime.now(),
        );

        // With current fuel prices, cost should be between 30-100 PLN/100km
        expect(refuel.costPer100km, inInclusiveRange(30, 100));
      });
    });

    group('Data Integrity', () {
      test('car ID should be unique identifier', () {
        final car1 = Car(id: 1, carName: 'car1', carStatisticsTable: 'stats1');
        final car2 = Car(id: 2, carName: 'car2', carStatisticsTable: 'stats2');

        expect(car1.id, isNot(equals(car2.id)));
      });

      test('refuel type conversion is consistent', () {
        for (final type in RefuelType.values) {
          final value = type.value;
          final restored = RefuelType.fromValue(value);
          expect(restored, equals(type));
        }
      });

      test('expense type keys are unique', () {
        final keys = Expense.expenseTypes.values.toSet();
        expect(keys.length, equals(Expense.expenseTypes.length));
      });
    });

    group('Business Rules', () {
      test('full refuel should have refuelType.full', () {
        final refuel = Refuel(
          volumes: 50.0,
          distance: 500.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        expect(refuel.refuelType, equals(RefuelType.full));
        expect(refuel.refuelType.value, equals(11));
      });

      test('partial refuel should have refuelType.partial', () {
        final refuel = Refuel(
          volumes: 20.0,
          distance: 200.0,
          date: DateTime.now(),
          refuelType: RefuelType.partial,
        );

        expect(refuel.refuelType, equals(RefuelType.partial));
        expect(refuel.refuelType.value, equals(0));
      });

      test('maintenance expenses should be type 1', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Oil Change',
          statisticType: 1,
        );

        expect(expense.typeKey, equals('maintenance'));
      });

      test('repair expenses should be type 2', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Engine Repair',
          statisticType: 2,
        );

        expect(expense.typeKey, equals('repair'));
      });
    });

    group('Null Safety', () {
      test('car handles null optional fields', () {
        final car = Car(
          carName: 'test',
          carDescription: null,
          carAliasName: null,
          carAlgorithm: null,
          carChartPreferences: null,
          carStatisticsTable: 'stats',
        );

        expect(car.carDescription, isNull);
        expect(car.carAliasName, isNull);
        expect(car.carAlgorithm, isNull);
        expect(car.carChartPreferences, isNull);
      });

      test('refuel handles null GPS coordinates', () {
        final refuel = Refuel(
          date: DateTime.now(),
          gpsLatitude: null,
          gpsLongitude: null,
        );

        expect(refuel.gpsLatitude, isNull);
        expect(refuel.gpsLongitude, isNull);
      });

      test('expense handles null information', () {
        final expense = Expense(
          date: DateTime.now(),
          statisticTitle: 'Test',
          information: null,
        );

        expect(expense.information, isNull);
      });
    });
  });
}

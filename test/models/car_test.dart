import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/car.dart';

void main() {
  group('Car Model Tests', () {
    group('Constructor', () {
      test('creates car with required fields', () {
        final car = Car(
          carName: 'test_car_table',
          carStatisticsTable: 'test_stats_table',
        );

        expect(car.id, isNull);
        expect(car.carName, equals('test_car_table'));
        expect(car.carStatisticsTable, equals('test_stats_table'));
        expect(car.carInitialMileage, equals(0));
        expect(car.carTraveledDistance, equals(0));
        expect(car.carRelativeVolume, equals(40.0));
        expect(car.carEnableRelativeVolume, equals(0));
      });

      test('creates car with all fields', () {
        final car = Car(
          id: 1,
          carName: 'test_car',
          carDescription: 'Test Description',
          carAliasName: 'My Car',
          carAlgorithm: 'standard',
          carInitialMileage: 50000,
          carTraveledDistance: 10000,
          carRelativeVolume: 55.0,
          carEnableRelativeVolume: 1,
          carChartPreferences: 'consumption',
          carStatisticsTable: 'stats_1',
        );

        expect(car.id, equals(1));
        expect(car.carDescription, equals('Test Description'));
        expect(car.carAliasName, equals('My Car'));
        expect(car.carAlgorithm, equals('standard'));
        expect(car.carInitialMileage, equals(50000));
        expect(car.carTraveledDistance, equals(10000));
        expect(car.carRelativeVolume, equals(55.0));
        expect(car.carEnableRelativeVolume, equals(1));
        expect(car.carChartPreferences, equals('consumption'));
      });
    });

    group('toMap', () {
      test('converts car to map with all fields', () {
        final car = Car(
          id: 1,
          carName: 'test_car',
          carDescription: 'Test Description',
          carAliasName: 'My Car',
          carAlgorithm: 'standard',
          carInitialMileage: 50000,
          carTraveledDistance: 10000,
          carRelativeVolume: 55.0,
          carEnableRelativeVolume: 1,
          carChartPreferences: 'consumption',
          carStatisticsTable: 'stats_1',
        );

        final map = car.toMap();

        expect(map['_car_id'], equals(1));
        expect(map['car_name'], equals('test_car'));
        expect(map['car_desctription'], equals('Test Description'));
        expect(map['car_alias_name'], equals('My Car'));
        expect(map['car_algoritm'], equals('standard'));
        expect(map['car_initial_millage'], equals(50000));
        expect(map['car_traveled_distance'], equals(10000));
        expect(map['car_relative_volume'], equals(55.0));
        expect(map['car_enable_relative_volume'], equals(1));
        expect(map['car_chart_preferences'], equals('consumption'));
        expect(map['car_statistics_table'], equals('stats_1'));
      });

      test('converts car to map with null optional fields', () {
        final car = Car(carName: 'test_car', carStatisticsTable: 'stats_1');

        final map = car.toMap();

        expect(map['_car_id'], isNull);
        expect(map['car_desctription'], isNull);
        expect(map['car_alias_name'], isNull);
        expect(map['car_algoritm'], isNull);
        expect(map['car_chart_preferences'], isNull);
      });
    });

    group('fromMap', () {
      test('creates car from complete map', () {
        final map = {
          '_car_id': 1,
          'car_name': 'test_car',
          'car_desctription': 'Test Description',
          'car_alias_name': 'My Car',
          'car_algoritm': 'standard',
          'car_initial_millage': 50000,
          'car_traveled_distance': 10000,
          'car_relative_volume': 55.0,
          'car_enable_relative_volume': 1,
          'car_chart_preferences': 'consumption',
          'car_statistics_table': 'stats_1',
        };

        final car = Car.fromMap(map);

        expect(car.id, equals(1));
        expect(car.carName, equals('test_car'));
        expect(car.carDescription, equals('Test Description'));
        expect(car.carAliasName, equals('My Car'));
        expect(car.carAlgorithm, equals('standard'));
        expect(car.carInitialMileage, equals(50000));
        expect(car.carTraveledDistance, equals(10000));
        expect(car.carRelativeVolume, equals(55.0));
        expect(car.carEnableRelativeVolume, equals(1));
        expect(car.carChartPreferences, equals('consumption'));
        expect(car.carStatisticsTable, equals('stats_1'));
      });

      test('creates car from map with missing optional fields', () {
        final map = {
          '_car_id': 1,
          'car_name': 'test_car',
          'car_statistics_table': 'stats_1',
        };

        final car = Car.fromMap(map);

        expect(car.id, equals(1));
        expect(car.carName, equals('test_car'));
        expect(car.carDescription, isNull);
        expect(car.carAliasName, isNull);
        expect(car.carAlgorithm, isNull);
        expect(car.carInitialMileage, equals(0));
        expect(car.carTraveledDistance, equals(0));
        expect(car.carRelativeVolume, equals(40.0));
        expect(car.carEnableRelativeVolume, equals(0));
        expect(car.carChartPreferences, isNull);
        expect(car.carStatisticsTable, equals('stats_1'));
      });

      test('handles null car_name gracefully', () {
        final map = {'_car_id': 1, 'car_statistics_table': 'stats_1'};

        final car = Car.fromMap(map);

        expect(car.carName, equals(''));
      });

      test('converts integer relative volume to double', () {
        final map = {
          '_car_id': 1,
          'car_name': 'test_car',
          'car_relative_volume': 50, // integer
          'car_statistics_table': 'stats_1',
        };

        final car = Car.fromMap(map);

        expect(car.carRelativeVolume, isA<double>());
        expect(car.carRelativeVolume, equals(50.0));
      });
    });

    group('copyWith', () {
      test('copies car with no changes', () {
        final car = Car(
          id: 1,
          carName: 'test_car',
          carDescription: 'Test Description',
          carStatisticsTable: 'stats_1',
        );

        final copiedCar = car.copyWith();

        expect(copiedCar.id, equals(car.id));
        expect(copiedCar.carName, equals(car.carName));
        expect(copiedCar.carDescription, equals(car.carDescription));
        expect(copiedCar.carStatisticsTable, equals(car.carStatisticsTable));
      });

      test('copies car with some changes', () {
        final car = Car(
          id: 1,
          carName: 'test_car',
          carDescription: 'Test Description',
          carStatisticsTable: 'stats_1',
        );

        final copiedCar = car.copyWith(
          carDescription: 'New Description',
          carInitialMileage: 100000,
        );

        expect(copiedCar.id, equals(1));
        expect(copiedCar.carName, equals('test_car'));
        expect(copiedCar.carDescription, equals('New Description'));
        expect(copiedCar.carInitialMileage, equals(100000));
        expect(copiedCar.carStatisticsTable, equals('stats_1'));
      });

      test('copies car with new id', () {
        final car = Car(carName: 'test_car', carStatisticsTable: 'stats_1');

        final copiedCar = car.copyWith(id: 5);

        expect(copiedCar.id, equals(5));
      });
    });

    group('roundtrip (toMap -> fromMap)', () {
      test('car survives roundtrip conversion', () {
        final originalCar = Car(
          id: 1,
          carName: 'test_car',
          carDescription: 'Test Description',
          carAliasName: 'My Car',
          carAlgorithm: 'standard',
          carInitialMileage: 50000,
          carTraveledDistance: 10000,
          carRelativeVolume: 55.0,
          carEnableRelativeVolume: 1,
          carChartPreferences: 'consumption',
          carStatisticsTable: 'stats_1',
        );

        final map = originalCar.toMap();
        final restoredCar = Car.fromMap(map);

        expect(restoredCar.id, equals(originalCar.id));
        expect(restoredCar.carName, equals(originalCar.carName));
        expect(restoredCar.carDescription, equals(originalCar.carDescription));
        expect(restoredCar.carAliasName, equals(originalCar.carAliasName));
        expect(restoredCar.carAlgorithm, equals(originalCar.carAlgorithm));
        expect(
          restoredCar.carInitialMileage,
          equals(originalCar.carInitialMileage),
        );
        expect(
          restoredCar.carTraveledDistance,
          equals(originalCar.carTraveledDistance),
        );
        expect(
          restoredCar.carRelativeVolume,
          equals(originalCar.carRelativeVolume),
        );
        expect(
          restoredCar.carEnableRelativeVolume,
          equals(originalCar.carEnableRelativeVolume),
        );
        expect(
          restoredCar.carChartPreferences,
          equals(originalCar.carChartPreferences),
        );
        expect(
          restoredCar.carStatisticsTable,
          equals(originalCar.carStatisticsTable),
        );
      });
    });
  });
}

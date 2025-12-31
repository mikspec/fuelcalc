import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';

void main() {
  group('Refuel Model Tests', () {
    final testDate = DateTime(2024, 1, 15, 10, 30, 0);

    group('Constructor', () {
      test('creates refuel with required fields', () {
        final refuel = Refuel(date: testDate);

        expect(refuel.id, isNull);
        expect(refuel.odometerState, equals(0.0));
        expect(refuel.volumes, equals(4.5));
        expect(refuel.prize, equals(4.0));
        expect(refuel.information, isNull);
        expect(refuel.rating, equals(5.0));
        expect(refuel.date, equals(testDate));
        expect(refuel.distance, equals(200.0));
        expect(refuel.gpsLatitude, isNull);
        expect(refuel.gpsLongitude, isNull);
        expect(refuel.refuelType, equals(RefuelType.partial));
      });

      test('creates refuel with all fields', () {
        final refuel = Refuel(
          id: 1,
          odometerState: 100000.0,
          volumes: 45.5,
          prize: 6.50,
          information: 'Shell station',
          rating: 4.5,
          date: testDate,
          distance: 550.0,
          gpsLatitude: 52.2297,
          gpsLongitude: 21.0122,
          refuelType: RefuelType.full,
        );

        expect(refuel.id, equals(1));
        expect(refuel.odometerState, equals(100000.0));
        expect(refuel.volumes, equals(45.5));
        expect(refuel.prize, equals(6.50));
        expect(refuel.information, equals('Shell station'));
        expect(refuel.rating, equals(4.5));
        expect(refuel.distance, equals(550.0));
        expect(refuel.gpsLatitude, equals(52.2297));
        expect(refuel.gpsLongitude, equals(21.0122));
        expect(refuel.refuelType, equals(RefuelType.full));
      });
    });

    group('Calculated Properties', () {
      test('consumption calculates liters per 100km', () {
        final refuel = Refuel(volumes: 50.0, distance: 500.0, date: testDate);

        expect(refuel.consumption, equals(10.0)); // 50/500*100 = 10 L/100km
      });

      test('consumption returns 0 when distance is 0', () {
        final refuel = Refuel(volumes: 50.0, distance: 0.0, date: testDate);

        expect(refuel.consumption, equals(0.0));
      });

      test('consumption handles various consumption rates', () {
        // Efficient car: 5 L/100km
        final efficientRefuel = Refuel(
          volumes: 25.0,
          distance: 500.0,
          date: testDate,
        );
        expect(efficientRefuel.consumption, equals(5.0));

        // Gas guzzler: 15 L/100km
        final inefficientRefuel = Refuel(
          volumes: 75.0,
          distance: 500.0,
          date: testDate,
        );
        expect(inefficientRefuel.consumption, equals(15.0));
      });

      test('totalCost calculates price * volume', () {
        final refuel = Refuel(volumes: 45.0, prize: 6.50, date: testDate);

        expect(refuel.totalCost, equals(292.50)); // 45 * 6.50
      });

      test('costPer100km calculates correctly', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 6.0,
          distance: 500.0,
          date: testDate,
        );

        // totalCost = 50 * 6 = 300
        // costPer100km = (300 / 500) * 100 = 60
        expect(refuel.costPer100km, equals(60.0));
      });

      test('costPer100km returns 0 when distance is 0', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 6.0,
          distance: 0.0,
          date: testDate,
        );

        expect(refuel.costPer100km, equals(0.0));
      });
    });

    group('toMap', () {
      test('converts refuel to map with all fields', () {
        final refuel = Refuel(
          id: 1,
          odometerState: 100000.0,
          volumes: 45.5,
          prize: 6.50,
          information: 'Shell station',
          rating: 4.5,
          date: DateTime(2024, 1, 15, 10, 30, 0),
          distance: 550.0,
          gpsLatitude: 52.2297,
          gpsLongitude: 21.0122,
          refuelType: RefuelType.full,
        );

        final map = refuel.toMap();

        expect(map['_id'], equals(1));
        expect(map['odometer_state'], equals(0.0)); // Always stored as 0.0
        expect(map['volumes'], equals(45.5));
        expect(map['prize'], equals(6.50));
        expect(map['information'], equals('Shell station'));
        expect(map['rating'], equals(4.5));
        expect(map['date'], equals('2024-01-15 10:30:00'));
        expect(map['distance'], equals(550.0));
        expect(map['gps_latitude'], equals(52.2297));
        expect(map['gps_longitude'], equals(21.0122));
        expect(map['refuel_type'], equals(11)); // RefuelType.full.value
      });

      test('converts partial refuel type correctly', () {
        final refuel = Refuel(date: testDate, refuelType: RefuelType.partial);

        final map = refuel.toMap();

        expect(map['refuel_type'], equals(0)); // RefuelType.partial.value
      });
    });

    group('fromMap', () {
      test('creates refuel from complete map', () {
        final map = {
          '_id': 1,
          'odometer_state': 100000.0,
          'volumes': 45.5,
          'prize': 6.50,
          'information': 'Shell station',
          'rating': 4.5,
          'date': '2024-01-15 10:30:00',
          'distance': 550.0,
          'gps_latitude': 52.2297,
          'gps_longitude': 21.0122,
          'refuel_type': 11,
        };

        final refuel = Refuel.fromMap(map);

        expect(refuel.id, equals(1));
        expect(refuel.volumes, equals(45.5));
        expect(refuel.prize, equals(6.50));
        expect(refuel.information, equals('Shell station'));
        expect(refuel.rating, equals(4.5));
        expect(refuel.date, equals(DateTime(2024, 1, 15, 10, 30, 0)));
        expect(refuel.distance, equals(550.0));
        expect(refuel.gpsLatitude, equals(52.2297));
        expect(refuel.gpsLongitude, equals(21.0122));
        expect(refuel.refuelType, equals(RefuelType.full));
      });

      test('creates refuel from map with missing optional fields', () {
        final map = {'_id': 1, 'date': '2024-01-15 10:30:00'};

        final refuel = Refuel.fromMap(map);

        expect(refuel.id, equals(1));
        expect(refuel.volumes, equals(4.5)); // default
        expect(refuel.prize, equals(4.0)); // default
        expect(refuel.information, isNull);
        expect(refuel.rating, equals(5.0)); // default
        expect(refuel.distance, equals(200.0)); // default
        expect(refuel.gpsLatitude, isNull);
        expect(refuel.gpsLongitude, isNull);
        expect(refuel.refuelType, equals(RefuelType.partial)); // default
      });

      test('parses ISO8601 date format', () {
        final map = {'_id': 1, 'date': '2024-01-15T10:30:00.000'};

        final refuel = Refuel.fromMap(map);

        expect(refuel.date.year, equals(2024));
        expect(refuel.date.month, equals(1));
        expect(refuel.date.day, equals(15));
      });

      test('converts integer values to double', () {
        final map = {
          '_id': 1,
          'volumes': 45, // integer
          'prize': 6, // integer
          'distance': 550, // integer
          'gps_latitude': 52, // integer
          'gps_longitude': 21, // integer
          'date': '2024-01-15 10:30:00',
        };

        final refuel = Refuel.fromMap(map);

        expect(refuel.volumes, isA<double>());
        expect(refuel.prize, isA<double>());
        expect(refuel.distance, isA<double>());
        expect(refuel.gpsLatitude, isA<double>());
        expect(refuel.gpsLongitude, isA<double>());
      });
    });

    group('copyWith', () {
      test('copies refuel with no changes', () {
        final refuel = Refuel(
          id: 1,
          volumes: 45.0,
          prize: 6.50,
          date: testDate,
          refuelType: RefuelType.full,
        );

        final copiedRefuel = refuel.copyWith();

        expect(copiedRefuel.id, equals(refuel.id));
        expect(copiedRefuel.volumes, equals(refuel.volumes));
        expect(copiedRefuel.prize, equals(refuel.prize));
        expect(copiedRefuel.date, equals(refuel.date));
        expect(copiedRefuel.refuelType, equals(refuel.refuelType));
      });

      test('copies refuel with some changes', () {
        final refuel = Refuel(
          id: 1,
          volumes: 45.0,
          prize: 6.50,
          date: testDate,
          distance: 500.0,
          refuelType: RefuelType.partial,
        );

        final copiedRefuel = refuel.copyWith(
          volumes: 50.0,
          refuelType: RefuelType.full,
        );

        expect(copiedRefuel.id, equals(1));
        expect(copiedRefuel.volumes, equals(50.0));
        expect(copiedRefuel.prize, equals(6.50)); // unchanged
        expect(copiedRefuel.distance, equals(500.0)); // unchanged
        expect(copiedRefuel.refuelType, equals(RefuelType.full));
      });

      test('copies refuel with GPS coordinates', () {
        final refuel = Refuel(date: testDate);

        final copiedRefuel = refuel.copyWith(
          gpsLatitude: 52.2297,
          gpsLongitude: 21.0122,
        );

        expect(copiedRefuel.gpsLatitude, equals(52.2297));
        expect(copiedRefuel.gpsLongitude, equals(21.0122));
      });
    });

    group('roundtrip (toMap -> fromMap)', () {
      test('refuel survives roundtrip conversion', () {
        final originalRefuel = Refuel(
          id: 1,
          volumes: 45.5,
          prize: 6.50,
          information: 'Shell station',
          rating: 4.5,
          date: DateTime(2024, 1, 15, 10, 30, 0),
          distance: 550.0,
          gpsLatitude: 52.2297,
          gpsLongitude: 21.0122,
          refuelType: RefuelType.full,
        );

        final map = originalRefuel.toMap();
        final restoredRefuel = Refuel.fromMap(map);

        expect(restoredRefuel.id, equals(originalRefuel.id));
        expect(restoredRefuel.volumes, equals(originalRefuel.volumes));
        expect(restoredRefuel.prize, equals(originalRefuel.prize));
        expect(restoredRefuel.information, equals(originalRefuel.information));
        expect(restoredRefuel.rating, equals(originalRefuel.rating));
        expect(restoredRefuel.date, equals(originalRefuel.date));
        expect(restoredRefuel.distance, equals(originalRefuel.distance));
        expect(restoredRefuel.gpsLatitude, equals(originalRefuel.gpsLatitude));
        expect(
          restoredRefuel.gpsLongitude,
          equals(originalRefuel.gpsLongitude),
        );
        expect(restoredRefuel.refuelType, equals(originalRefuel.refuelType));
      });
    });
  });
}

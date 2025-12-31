import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/refuel.dart';
import 'package:fuelcalc/models/refuel_type.dart';

/// Tests for fuel consumption calculations with partial and full refuels.
/// These tests validate the complex business logic around consumption calculation.
void main() {
  group('Fuel Consumption Calculation Tests', () {
    group('Single refuel calculations', () {
      test('full tank consumption calculation', () {
        final refuel = Refuel(
          volumes: 50.0,
          distance: 500.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        // 50L / 500km * 100 = 10 L/100km
        expect(refuel.consumption, equals(10.0));
      });

      test('partial tank consumption calculation', () {
        final refuel = Refuel(
          volumes: 30.0,
          distance: 400.0,
          date: DateTime.now(),
          refuelType: RefuelType.partial,
        );

        // 30L / 400km * 100 = 7.5 L/100km
        expect(refuel.consumption, equals(7.5));
      });

      test('efficient car consumption (5 L/100km)', () {
        final refuel = Refuel(
          volumes: 35.0,
          distance: 700.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        // 35L / 700km * 100 = 5 L/100km
        expect(refuel.consumption, equals(5.0));
      });

      test('high consumption car (15 L/100km)', () {
        final refuel = Refuel(
          volumes: 90.0,
          distance: 600.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        // 90L / 600km * 100 = 15 L/100km
        expect(refuel.consumption, equals(15.0));
      });
    });

    group('Cost calculations', () {
      test('total cost calculation', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 6.50,
          distance: 500.0,
          date: DateTime.now(),
        );

        // 50L * 6.50 PLN/L = 325 PLN
        expect(refuel.totalCost, equals(325.0));
      });

      test('cost per 100km calculation', () {
        final refuel = Refuel(
          volumes: 50.0,
          prize: 6.50,
          distance: 500.0,
          date: DateTime.now(),
        );

        // Total cost = 325 PLN, cost per 100km = (325/500)*100 = 65 PLN/100km
        expect(refuel.costPer100km, equals(65.0));
      });

      test('expensive fuel cost per 100km', () {
        final refuel = Refuel(
          volumes: 45.0,
          prize: 8.0, // expensive fuel
          distance: 450.0,
          date: DateTime.now(),
        );

        // Total cost = 360 PLN, cost per 100km = (360/450)*100 = 80 PLN/100km
        expect(refuel.costPer100km, equals(80.0));
      });
    });

    group('Edge cases', () {
      test('zero distance returns zero consumption', () {
        final refuel = Refuel(
          volumes: 50.0,
          distance: 0.0,
          date: DateTime.now(),
        );

        expect(refuel.consumption, equals(0.0));
        expect(refuel.costPer100km, equals(0.0));
      });

      test('very short trip', () {
        final refuel = Refuel(
          volumes: 5.0,
          distance: 10.0,
          date: DateTime.now(),
        );

        // 5L / 10km * 100 = 50 L/100km (city driving, short trip)
        expect(refuel.consumption, equals(50.0));
      });

      test('very long trip', () {
        final refuel = Refuel(
          volumes: 80.0,
          distance: 1200.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
        );

        // 80L / 1200km * 100 = 6.67 L/100km (highway driving)
        expect(refuel.consumption, closeTo(6.67, 0.01));
      });
    });

    group('Multiple refuels scenario simulation', () {
      test('sequence of full refuels', () {
        final refuels = [
          Refuel(
            id: 1,
            volumes: 45.0,
            prize: 6.50,
            distance: 500.0,
            date: DateTime(2024, 1, 15),
            refuelType: RefuelType.full,
          ),
          Refuel(
            id: 2,
            volumes: 50.0,
            prize: 6.80,
            distance: 550.0,
            date: DateTime(2024, 1, 22),
            refuelType: RefuelType.full,
          ),
          Refuel(
            id: 3,
            volumes: 42.0,
            prize: 6.60,
            distance: 480.0,
            date: DateTime(2024, 1, 29),
            refuelType: RefuelType.full,
          ),
        ];

        // Calculate average consumption
        final totalVolume = refuels.fold(0.0, (sum, r) => sum + r.volumes);
        final totalDistance = refuels.fold(0.0, (sum, r) => sum + r.distance);
        final avgConsumption = (totalVolume / totalDistance) * 100;

        // (45+50+42) / (500+550+480) * 100 = 137 / 1530 * 100 = 8.95 L/100km
        expect(avgConsumption, closeTo(8.95, 0.01));

        // Calculate total cost
        final totalCost = refuels.fold(0.0, (sum, r) => sum + r.totalCost);
        // 45*6.50 + 50*6.80 + 42*6.60 = 292.50 + 340 + 277.20 = 909.70 PLN
        expect(totalCost, closeTo(909.70, 0.01));
      });

      test('mixed partial and full refuels scenario', () {
        // Simulating: full -> partial -> partial -> full
        final refuels = [
          Refuel(
            id: 1,
            volumes: 45.0,
            distance: 500.0,
            date: DateTime(2024, 1, 10),
            refuelType: RefuelType.full,
          ),
          Refuel(
            id: 2,
            volumes: 20.0,
            distance: 200.0,
            date: DateTime(2024, 1, 15),
            refuelType: RefuelType.partial,
          ),
          Refuel(
            id: 3,
            volumes: 15.0,
            distance: 180.0,
            date: DateTime(2024, 1, 18),
            refuelType: RefuelType.partial,
          ),
          Refuel(
            id: 4,
            volumes: 40.0,
            distance: 420.0,
            date: DateTime(2024, 1, 25),
            refuelType: RefuelType.full,
          ),
        ];

        // Total volume
        final totalVolume = refuels.fold(0.0, (sum, r) => sum + r.volumes);
        expect(totalVolume, equals(120.0));

        // Total distance
        final totalDistance = refuels.fold(0.0, (sum, r) => sum + r.distance);
        expect(totalDistance, equals(1300.0));
      });
    });

    group('Real-world scenarios', () {
      test('city driving scenario (high consumption)', () {
        final refuel = Refuel(
          volumes: 40.0,
          distance: 250.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
          information: 'City driving only',
        );

        // 40L / 250km * 100 = 16 L/100km
        expect(refuel.consumption, equals(16.0));
      });

      test('highway driving scenario (low consumption)', () {
        final refuel = Refuel(
          volumes: 55.0,
          distance: 850.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
          information: 'Highway trip to coast',
        );

        // 55L / 850km * 100 = 6.47 L/100km
        expect(refuel.consumption, closeTo(6.47, 0.01));
      });

      test('mixed driving scenario', () {
        final refuel = Refuel(
          volumes: 48.0,
          distance: 520.0,
          date: DateTime.now(),
          refuelType: RefuelType.full,
          information: 'Mixed city and highway',
        );

        // 48L / 520km * 100 = 9.23 L/100km
        expect(refuel.consumption, closeTo(9.23, 0.01));
      });
    });
  });
}

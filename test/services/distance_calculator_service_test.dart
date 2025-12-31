import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/services/distance_calculator_service.dart';

void main() {
  group('DistanceCalculatorService Tests', () {
    group('formatDistance', () {
      test('formats positive distance correctly', () {
        expect(
          DistanceCalculatorService.formatDistance(500.0),
          equals('500 km'),
        );
      });

      test('formats large distance correctly', () {
        expect(
          DistanceCalculatorService.formatDistance(12500.0),
          equals('12500 km'),
        );
      });

      test('returns 0 km for zero distance', () {
        expect(DistanceCalculatorService.formatDistance(0.0), equals('0 km'));
      });

      test('returns 0 km for negative distance', () {
        expect(
          DistanceCalculatorService.formatDistance(-100.0),
          equals('0 km'),
        );
      });

      test('rounds decimal values', () {
        expect(
          DistanceCalculatorService.formatDistance(500.7),
          equals('501 km'),
        );
        expect(
          DistanceCalculatorService.formatDistance(500.3),
          equals('500 km'),
        );
      });
    });

    group('isValidOdometerReading', () {
      test('returns false for zero odometer', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(0.0, null),
          isFalse,
        );
      });

      test('returns false for negative odometer', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(-100.0, null),
          isFalse,
        );
      });

      test('returns true for positive odometer with null last reading', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(1000.0, null),
          isTrue,
        );
      });

      test('returns true for positive odometer with zero last reading', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(1000.0, 0.0),
          isTrue,
        );
      });

      test('returns true when current is greater than last', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(2000.0, 1000.0),
          isTrue,
        );
      });

      test('returns false when current equals last', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(1000.0, 1000.0),
          isFalse,
        );
      });

      test('returns false when current is less than last', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(500.0, 1000.0),
          isFalse,
        );
      });

      test('handles edge case with negative last reading', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(100.0, -50.0),
          isTrue,
        );
      });
    });

    group('Edge cases', () {
      test('formatDistance handles very large numbers', () {
        final result = DistanceCalculatorService.formatDistance(999999.9);
        expect(result, equals('1000000 km'));
      });

      test('formatDistance handles small positive numbers', () {
        final result = DistanceCalculatorService.formatDistance(0.1);
        expect(result, equals('0 km'));
      });

      test('isValidOdometerReading handles very large numbers', () {
        expect(
          DistanceCalculatorService.isValidOdometerReading(
            999999999.0,
            999999998.0,
          ),
          isTrue,
        );
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/refuel_type.dart';

void main() {
  group('RefuelType Enum Tests', () {
    group('enum values', () {
      test('partial has value 0', () {
        expect(RefuelType.partial.value, equals(0));
      });

      test('full has value 11', () {
        expect(RefuelType.full.value, equals(11));
      });

      test('enum has exactly 2 values', () {
        expect(RefuelType.values.length, equals(2));
      });
    });

    group('fromValue', () {
      test('returns partial for value 0', () {
        expect(RefuelType.fromValue(0), equals(RefuelType.partial));
      });

      test('returns full for value 11', () {
        expect(RefuelType.fromValue(11), equals(RefuelType.full));
      });

      test('returns partial for unknown value (default)', () {
        expect(RefuelType.fromValue(1), equals(RefuelType.partial));
        expect(RefuelType.fromValue(5), equals(RefuelType.partial));
        expect(RefuelType.fromValue(10), equals(RefuelType.partial));
        expect(RefuelType.fromValue(99), equals(RefuelType.partial));
        expect(RefuelType.fromValue(-1), equals(RefuelType.partial));
      });
    });

    group('roundtrip', () {
      test('partial survives roundtrip', () {
        final original = RefuelType.partial;
        final restored = RefuelType.fromValue(original.value);
        expect(restored, equals(original));
      });

      test('full survives roundtrip', () {
        final original = RefuelType.full;
        final restored = RefuelType.fromValue(original.value);
        expect(restored, equals(original));
      });
    });
  });
}

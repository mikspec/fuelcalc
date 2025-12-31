import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/utils/constants.dart';

void main() {
  group('Constants Tests', () {
    group('File prefix constant', () {
      test('kFuelcalcFilePrefix has correct value', () {
        expect(kFuelcalcFilePrefix, equals('fuel'));
      });

      test('kFuelcalcFilePrefix is non-empty', () {
        expect(kFuelcalcFilePrefix.isNotEmpty, isTrue);
      });
    });

    group('Database name constant', () {
      test('kFuelcalcDatabaseName has correct value', () {
        expect(kFuelcalcDatabaseName, equals('fuel.sqlite'));
      });

      test('kFuelcalcDatabaseName has .sqlite extension', () {
        expect(kFuelcalcDatabaseName.endsWith('.sqlite'), isTrue);
      });

      test('kFuelcalcDatabaseName starts with file prefix', () {
        expect(kFuelcalcDatabaseName.startsWith(kFuelcalcFilePrefix), isTrue);
      });
    });
  });
}

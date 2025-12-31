import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    final testDate = DateTime(2024, 1, 15, 10, 30, 0);

    group('Constructor', () {
      test('creates expense with required fields', () {
        final expense = Expense(date: testDate, statisticTitle: 'Oil change');

        expect(expense.id, isNull);
        expect(expense.date, equals(testDate));
        expect(expense.information, isNull);
        expect(expense.statisticTitle, equals('Oil change'));
        expect(expense.statisticCost, equals(0.0));
        expect(expense.statisticType, equals(0));
        expect(expense.statisticSubtype, equals(0));
        expect(expense.statisticRating, equals(5.0));
      });

      test('creates expense with all fields', () {
        final expense = Expense(
          id: 1,
          date: testDate,
          information: 'Synthetic oil 5W-30',
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1, // maintenance
          statisticSubtype: 0,
          statisticRating: 4.5,
        );

        expect(expense.id, equals(1));
        expect(expense.date, equals(testDate));
        expect(expense.information, equals('Synthetic oil 5W-30'));
        expect(expense.statisticTitle, equals('Oil change'));
        expect(expense.statisticCost, equals(350.0));
        expect(expense.statisticType, equals(1));
        expect(expense.statisticSubtype, equals(0));
        expect(expense.statisticRating, equals(4.5));
      });
    });

    group('typeKey getter', () {
      test('returns correct key for maintenance type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Oil change',
          statisticType: 1,
        );

        expect(expense.typeKey, equals('maintenance'));
      });

      test('returns correct key for repair type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Brake replacement',
          statisticType: 2,
        );

        expect(expense.typeKey, equals('repair'));
      });

      test('returns correct key for towing type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Tow service',
          statisticType: 3,
        );

        expect(expense.typeKey, equals('towing'));
      });

      test('returns correct key for insurance type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Annual insurance',
          statisticType: 4,
        );

        expect(expense.typeKey, equals('insurance'));
      });

      test('returns correct key for inspection type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Annual inspection',
          statisticType: 5,
        );

        expect(expense.typeKey, equals('inspection'));
      });

      test('returns correct key for other type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Car wash',
          statisticType: 0,
        );

        expect(expense.typeKey, equals('other'));
      });

      test('returns unknown for invalid type', () {
        final expense = Expense(
          date: testDate,
          statisticTitle: 'Unknown expense',
          statisticType: 99, // invalid type
        );

        expect(expense.typeKey, equals('unknown'));
      });
    });

    group('expenseTypes static map', () {
      test('contains all expected expense types', () {
        expect(Expense.expenseTypes.length, equals(6));
        expect(Expense.expenseTypes[0], equals('other'));
        expect(Expense.expenseTypes[1], equals('maintenance'));
        expect(Expense.expenseTypes[2], equals('repair'));
        expect(Expense.expenseTypes[3], equals('towing'));
        expect(Expense.expenseTypes[4], equals('insurance'));
        expect(Expense.expenseTypes[5], equals('inspection'));
      });
    });

    group('toMap', () {
      test('converts expense to map with all fields', () {
        final expense = Expense(
          id: 1,
          date: DateTime(2024, 1, 15, 10, 30, 0),
          information: 'Synthetic oil 5W-30',
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1,
          statisticSubtype: 0,
          statisticRating: 4.5,
        );

        final map = expense.toMap();

        expect(map['_statistics_row_id'], equals(1));
        expect(map['date'], equals('2024-01-15 10:30:00'));
        expect(map['information'], equals('Synthetic oil 5W-30'));
        expect(map['statistic_title'], equals('Oil change'));
        expect(map['statistic_cost'], equals(350.0));
        expect(map['statistic_type'], equals(1));
        expect(map['statistic_subtype'], equals(0));
        expect(map['statistic_rating'], equals(4.5));
      });

      test('converts expense to map with null optional fields', () {
        final expense = Expense(date: testDate, statisticTitle: 'Oil change');

        final map = expense.toMap();

        expect(map['_statistics_row_id'], isNull);
        expect(map['information'], isNull);
      });
    });

    group('fromMap', () {
      test('creates expense from complete map', () {
        final map = {
          '_statistics_row_id': 1,
          'date': '2024-01-15 10:30:00',
          'information': 'Synthetic oil 5W-30',
          'statistic_title': 'Oil change',
          'statistic_cost': 350.0,
          'statistic_type': 1,
          'statistic_subtype': 0,
          'statistic_rating': 4.5,
        };

        final expense = Expense.fromMap(map);

        expect(expense.id, equals(1));
        expect(expense.date, equals(DateTime(2024, 1, 15, 10, 30, 0)));
        expect(expense.information, equals('Synthetic oil 5W-30'));
        expect(expense.statisticTitle, equals('Oil change'));
        expect(expense.statisticCost, equals(350.0));
        expect(expense.statisticType, equals(1));
        expect(expense.statisticSubtype, equals(0));
        expect(expense.statisticRating, equals(4.5));
      });

      test('creates expense from map with missing optional fields', () {
        final map = {
          '_statistics_row_id': 1,
          'date': '2024-01-15 10:30:00',
          'statistic_title': 'Oil change',
        };

        final expense = Expense.fromMap(map);

        expect(expense.id, equals(1));
        expect(expense.information, isNull);
        expect(expense.statisticCost, equals(0.0));
        expect(expense.statisticType, equals(0));
        expect(expense.statisticSubtype, equals(0));
        expect(expense.statisticRating, equals(5.0));
      });

      test('parses ISO8601 date format', () {
        final map = {
          '_statistics_row_id': 1,
          'date': '2024-01-15T10:30:00.000',
          'statistic_title': 'Oil change',
        };

        final expense = Expense.fromMap(map);

        expect(expense.date.year, equals(2024));
        expect(expense.date.month, equals(1));
        expect(expense.date.day, equals(15));
      });

      test('converts integer cost to double', () {
        final map = {
          '_statistics_row_id': 1,
          'date': '2024-01-15 10:30:00',
          'statistic_title': 'Oil change',
          'statistic_cost': 350, // integer
        };

        final expense = Expense.fromMap(map);

        expect(expense.statisticCost, isA<double>());
        expect(expense.statisticCost, equals(350.0));
      });

      test('handles null statistic_title gracefully', () {
        final map = {'_statistics_row_id': 1, 'date': '2024-01-15 10:30:00'};

        final expense = Expense.fromMap(map);

        expect(expense.statisticTitle, equals(''));
      });
    });

    group('copyWith', () {
      test('copies expense with no changes', () {
        final expense = Expense(
          id: 1,
          date: testDate,
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1,
        );

        final copiedExpense = expense.copyWith();

        expect(copiedExpense.id, equals(expense.id));
        expect(copiedExpense.date, equals(expense.date));
        expect(copiedExpense.statisticTitle, equals(expense.statisticTitle));
        expect(copiedExpense.statisticCost, equals(expense.statisticCost));
        expect(copiedExpense.statisticType, equals(expense.statisticType));
      });

      test('copies expense with some changes', () {
        final expense = Expense(
          id: 1,
          date: testDate,
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1,
        );

        final copiedExpense = expense.copyWith(
          statisticCost: 400.0,
          information: 'Full synthetic',
        );

        expect(copiedExpense.id, equals(1)); // unchanged
        expect(copiedExpense.statisticTitle, equals('Oil change')); // unchanged
        expect(copiedExpense.statisticCost, equals(400.0));
        expect(copiedExpense.information, equals('Full synthetic'));
      });

      test('copies expense with new date', () {
        final expense = Expense(date: testDate, statisticTitle: 'Oil change');

        final newDate = DateTime(2024, 6, 15);
        final copiedExpense = expense.copyWith(date: newDate);

        expect(copiedExpense.date, equals(newDate));
      });
    });

    group('roundtrip (toMap -> fromMap)', () {
      test('expense survives roundtrip conversion', () {
        final originalExpense = Expense(
          id: 1,
          date: DateTime(2024, 1, 15, 10, 30, 0),
          information: 'Synthetic oil 5W-30',
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1,
          statisticSubtype: 0,
          statisticRating: 4.5,
        );

        final map = originalExpense.toMap();
        final restoredExpense = Expense.fromMap(map);

        expect(restoredExpense.id, equals(originalExpense.id));
        expect(restoredExpense.date, equals(originalExpense.date));
        expect(
          restoredExpense.information,
          equals(originalExpense.information),
        );
        expect(
          restoredExpense.statisticTitle,
          equals(originalExpense.statisticTitle),
        );
        expect(
          restoredExpense.statisticCost,
          equals(originalExpense.statisticCost),
        );
        expect(
          restoredExpense.statisticType,
          equals(originalExpense.statisticType),
        );
        expect(
          restoredExpense.statisticSubtype,
          equals(originalExpense.statisticSubtype),
        );
        expect(
          restoredExpense.statisticRating,
          equals(originalExpense.statisticRating),
        );
      });
    });
  });
}

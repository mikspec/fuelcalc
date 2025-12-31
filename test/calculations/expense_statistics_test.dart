import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/models/expense.dart';

/// Tests for expense-related calculations and statistics.
void main() {
  group('Expense Statistics Calculation Tests', () {
    group('Single expense calculations', () {
      test('expense with maintenance type', () {
        final expense = Expense(
          id: 1,
          date: DateTime(2024, 1, 15),
          statisticTitle: 'Oil change',
          statisticCost: 350.0,
          statisticType: 1, // maintenance
        );

        expect(expense.statisticCost, equals(350.0));
        expect(expense.typeKey, equals('maintenance'));
      });

      test('expense with repair type', () {
        final expense = Expense(
          id: 2,
          date: DateTime(2024, 2, 20),
          statisticTitle: 'Brake pads replacement',
          statisticCost: 800.0,
          statisticType: 2, // repair
        );

        expect(expense.statisticCost, equals(800.0));
        expect(expense.typeKey, equals('repair'));
      });
    });

    group('Multiple expenses calculations', () {
      test('total cost calculation', () {
        final expenses = [
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'Oil change',
            statisticCost: 350.0,
            statisticType: 1,
          ),
          Expense(
            date: DateTime(2024, 2, 20),
            statisticTitle: 'Brake pads',
            statisticCost: 800.0,
            statisticType: 2,
          ),
          Expense(
            date: DateTime(2024, 3, 10),
            statisticTitle: 'Insurance',
            statisticCost: 2500.0,
            statisticType: 4,
          ),
        ];

        final totalCost = expenses.fold(0.0, (sum, e) => sum + e.statisticCost);

        expect(totalCost, equals(3650.0));
      });

      test('average cost calculation', () {
        final expenses = [
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'Oil change',
            statisticCost: 300.0,
            statisticType: 1,
          ),
          Expense(
            date: DateTime(2024, 2, 20),
            statisticTitle: 'Filter change',
            statisticCost: 200.0,
            statisticType: 1,
          ),
          Expense(
            date: DateTime(2024, 3, 10),
            statisticTitle: 'Windshield wipers',
            statisticCost: 100.0,
            statisticType: 0,
          ),
        ];

        final totalCost = expenses.fold(0.0, (sum, e) => sum + e.statisticCost);
        final avgCost = totalCost / expenses.length;

        expect(avgCost, equals(200.0));
      });

      test('costs grouped by category', () {
        final expenses = [
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'Oil change',
            statisticCost: 350.0,
            statisticType: 1, // maintenance
          ),
          Expense(
            date: DateTime(2024, 1, 20),
            statisticTitle: 'Filters',
            statisticCost: 150.0,
            statisticType: 1, // maintenance
          ),
          Expense(
            date: DateTime(2024, 2, 15),
            statisticTitle: 'Brake pads',
            statisticCost: 800.0,
            statisticType: 2, // repair
          ),
          Expense(
            date: DateTime(2024, 3, 1),
            statisticTitle: 'Insurance',
            statisticCost: 2500.0,
            statisticType: 4, // insurance
          ),
        ];

        // Group costs by type
        final categoryCosts = <int, double>{};
        for (final expense in expenses) {
          categoryCosts[expense.statisticType] =
              (categoryCosts[expense.statisticType] ?? 0.0) +
              expense.statisticCost;
        }

        expect(categoryCosts[1], equals(500.0)); // maintenance: 350 + 150
        expect(categoryCosts[2], equals(800.0)); // repair: 800
        expect(categoryCosts[4], equals(2500.0)); // insurance: 2500
      });
    });

    group('Expense type distribution', () {
      test('count expenses by type', () {
        final expenses = [
          Expense(date: DateTime.now(), statisticTitle: 'A', statisticType: 1),
          Expense(date: DateTime.now(), statisticTitle: 'B', statisticType: 1),
          Expense(date: DateTime.now(), statisticTitle: 'C', statisticType: 2),
          Expense(date: DateTime.now(), statisticTitle: 'D', statisticType: 1),
          Expense(date: DateTime.now(), statisticTitle: 'E', statisticType: 4),
          Expense(date: DateTime.now(), statisticTitle: 'F', statisticType: 2),
        ];

        final typeCounts = <int, int>{};
        for (final expense in expenses) {
          typeCounts[expense.statisticType] =
              (typeCounts[expense.statisticType] ?? 0) + 1;
        }

        expect(typeCounts[1], equals(3)); // maintenance
        expect(typeCounts[2], equals(2)); // repair
        expect(typeCounts[4], equals(1)); // insurance
      });
    });

    group('Date-based calculations', () {
      test('filter expenses by date range', () {
        final expenses = [
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'January expense',
            statisticCost: 100.0,
            statisticType: 0,
          ),
          Expense(
            date: DateTime(2024, 2, 15),
            statisticTitle: 'February expense',
            statisticCost: 200.0,
            statisticType: 0,
          ),
          Expense(
            date: DateTime(2024, 3, 15),
            statisticTitle: 'March expense',
            statisticCost: 300.0,
            statisticType: 0,
          ),
          Expense(
            date: DateTime(2024, 4, 15),
            statisticTitle: 'April expense',
            statisticCost: 400.0,
            statisticType: 0,
          ),
        ];

        final startDate = DateTime(2024, 2, 1);
        final endDate = DateTime(2024, 3, 31);

        final filteredExpenses = expenses
            .where(
              (e) =>
                  e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  e.date.isBefore(endDate.add(const Duration(days: 1))),
            )
            .toList();

        expect(filteredExpenses.length, equals(2));
        expect(filteredExpenses[0].statisticTitle, equals('February expense'));
        expect(filteredExpenses[1].statisticTitle, equals('March expense'));

        final filteredTotal = filteredExpenses.fold(
          0.0,
          (sum, e) => sum + e.statisticCost,
        );
        expect(filteredTotal, equals(500.0)); // 200 + 300
      });

      test('sort expenses by date descending', () {
        final expenses = [
          Expense(
            date: DateTime(2024, 2, 15),
            statisticTitle: 'Second',
            statisticType: 0,
          ),
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'Third',
            statisticType: 0,
          ),
          Expense(
            date: DateTime(2024, 3, 15),
            statisticTitle: 'First',
            statisticType: 0,
          ),
        ];

        expenses.sort((a, b) => b.date.compareTo(a.date));

        expect(expenses[0].statisticTitle, equals('First'));
        expect(expenses[1].statisticTitle, equals('Second'));
        expect(expenses[2].statisticTitle, equals('Third'));
      });
    });

    group('Real-world expense scenarios', () {
      test('annual maintenance costs', () {
        final annualExpenses = [
          // Oil changes
          Expense(
            date: DateTime(2024, 1, 15),
            statisticTitle: 'Oil change',
            statisticCost: 350.0,
            statisticType: 1,
          ),
          Expense(
            date: DateTime(2024, 7, 15),
            statisticTitle: 'Oil change',
            statisticCost: 380.0,
            statisticType: 1,
          ),
          // Insurance
          Expense(
            date: DateTime(2024, 3, 1),
            statisticTitle: 'Annual insurance',
            statisticCost: 2800.0,
            statisticType: 4,
          ),
          // Inspection
          Expense(
            date: DateTime(2024, 4, 10),
            statisticTitle: 'Technical inspection',
            statisticCost: 150.0,
            statisticType: 5,
          ),
          // Repairs
          Expense(
            date: DateTime(2024, 6, 20),
            statisticTitle: 'Brake pads',
            statisticCost: 750.0,
            statisticType: 2,
          ),
          Expense(
            date: DateTime(2024, 9, 5),
            statisticTitle: 'Tire change',
            statisticCost: 200.0,
            statisticType: 1,
          ),
        ];

        final totalAnnualCost = annualExpenses.fold(
          0.0,
          (sum, e) => sum + e.statisticCost,
        );

        // 350 + 380 + 2800 + 150 + 750 + 200 = 4630 PLN
        expect(totalAnnualCost, equals(4630.0));

        // Monthly average
        final monthlyAverage = totalAnnualCost / 12;
        expect(monthlyAverage, closeTo(385.83, 0.01));
      });

      test('unexpected repair costs', () {
        final unexpectedRepairs = [
          Expense(
            date: DateTime(2024, 5, 10),
            statisticTitle: 'Engine repair',
            statisticCost: 3500.0,
            statisticType: 2,
          ),
          Expense(
            date: DateTime(2024, 8, 22),
            statisticTitle: 'AC compressor',
            statisticCost: 1800.0,
            statisticType: 2,
          ),
          Expense(
            date: DateTime(2024, 9, 15),
            statisticTitle: 'Towing service',
            statisticCost: 400.0,
            statisticType: 3,
          ),
        ];

        final totalRepairCost = unexpectedRepairs.fold(
          0.0,
          (sum, e) => sum + e.statisticCost,
        );

        expect(totalRepairCost, equals(5700.0));

        // Find most expensive repair
        final mostExpensive = unexpectedRepairs.reduce(
          (a, b) => a.statisticCost > b.statisticCost ? a : b,
        );

        expect(mostExpensive.statisticTitle, equals('Engine repair'));
        expect(mostExpensive.statisticCost, equals(3500.0));
      });
    });
  });
}

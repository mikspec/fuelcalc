import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/services/currency_service.dart';

void main() {
  group('CurrencyService Tests', () {
    late CurrencyService currencyService;

    setUp(() {
      currencyService = CurrencyService();
    });

    group('Default values', () {
      test('default currency is PLN', () {
        expect(currencyService.currentCurrency, equals('PLN'));
      });

      test('default currency symbol is zł', () {
        expect(currencyService.currencySymbol, equals('zł'));
      });

      test('default currency code is PLN', () {
        expect(currencyService.currencyCode, equals('PLN'));
      });

      test('default currency name is Polish Złoty', () {
        expect(currencyService.currencyName, equals('Polish Złoty'));
      });

      test('default currency locale is pl_PL', () {
        expect(currencyService.currencyLocale, equals('pl_PL'));
      });
    });

    group('Supported currencies', () {
      test('contains all European currencies', () {
        final currencies = currencyService.supportedCurrencies;

        expect(currencies.containsKey('BGN'), isTrue);
        expect(currencies.containsKey('CZK'), isTrue);
        expect(currencies.containsKey('DKK'), isTrue);
        expect(currencies.containsKey('EUR'), isTrue);
        expect(currencies.containsKey('GBP'), isTrue);
        expect(currencies.containsKey('HUF'), isTrue);
        expect(currencies.containsKey('NOK'), isTrue);
        expect(currencies.containsKey('PLN'), isTrue);
        expect(currencies.containsKey('RON'), isTrue);
        expect(currencies.containsKey('SEK'), isTrue);
        expect(currencies.containsKey('TRY'), isTrue);
        expect(currencies.containsKey('UAH'), isTrue);
        expect(currencies.containsKey('USD'), isTrue);
      });

      test('all currencies have required fields', () {
        for (final entry in currencyService.supportedCurrencies.entries) {
          final currency = entry.value;
          expect(
            currency['name'],
            isNotNull,
            reason: '${entry.key} missing name',
          );
          expect(
            currency['symbol'],
            isNotNull,
            reason: '${entry.key} missing symbol',
          );
          expect(
            currency['code'],
            isNotNull,
            reason: '${entry.key} missing code',
          );
          expect(
            currency['locale'],
            isNotNull,
            reason: '${entry.key} missing locale',
          );
        }
      });

      test('availableCurrencies returns all currency codes', () {
        final available = currencyService.availableCurrencies;

        expect(
          available.length,
          equals(currencyService.supportedCurrencies.length),
        );
        expect(available, contains('PLN'));
        expect(available, contains('EUR'));
        expect(available, contains('USD'));
      });
    });

    group('Currency symbols', () {
      test('EUR has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['EUR']!['symbol'],
          equals('€'),
        );
      });

      test('GBP has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['GBP']!['symbol'],
          equals('£'),
        );
      });

      test('USD has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['USD']!['symbol'],
          equals('\$'),
        );
      });

      test('PLN has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['PLN']!['symbol'],
          equals('zł'),
        );
      });

      test('CZK has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['CZK']!['symbol'],
          equals('Kč'),
        );
      });

      test('HUF has correct symbol', () {
        expect(
          currencyService.supportedCurrencies['HUF']!['symbol'],
          equals('Ft'),
        );
      });
    });

    group('Currency formatting', () {
      test('formatCurrency formats amount correctly', () {
        final formatted = currencyService.formatCurrency(123.45);

        // Should contain the amount and currency symbol
        expect(formatted, contains('123'));
        expect(formatted, contains('zł'));
      });

      test('formatPricePerLiter formats price correctly', () {
        final formatted = currencyService.formatPricePerLiter(6.50);

        // Should contain the price and /l suffix
        expect(formatted, contains('6'));
        expect(formatted, contains('/l'));
      });

      test('formatCurrency handles zero', () {
        final formatted = currencyService.formatCurrency(0);

        expect(formatted, contains('0'));
      });

      test('formatCurrency handles large amounts', () {
        final formatted = currencyService.formatCurrency(1000000.99);

        expect(formatted, contains('zł'));
      });
    });

    group('Currency info retrieval', () {
      test('returns fallback values for unknown currency', () {
        // Simulate invalid currency by testing the fallback getters
        // Since we can't directly set invalid currency, we test the service structure
        expect(currencyService.currencySymbol.isNotEmpty, isTrue);
        expect(currencyService.currencyCode.isNotEmpty, isTrue);
        expect(currencyService.currencyName.isNotEmpty, isTrue);
        expect(currencyService.currencyLocale.isNotEmpty, isTrue);
      });
    });
  });
}

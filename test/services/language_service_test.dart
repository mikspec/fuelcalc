import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelcalc/services/language_service.dart';

void main() {
  group('LanguageService Tests', () {
    late LanguageService languageService;

    setUp(() {
      languageService = LanguageService();
    });

    group('Default values', () {
      test('default locale is Polish', () {
        expect(languageService.currentLocale, equals(const Locale('pl')));
      });
    });

    group('Supported locales', () {
      test('supports Polish and English', () {
        final locales = languageService.supportedLocales;

        expect(locales.length, equals(2));
        expect(locales, contains(const Locale('pl')));
        expect(locales, contains(const Locale('en')));
      });

      test('supportedLocales is immutable list', () {
        final locales1 = languageService.supportedLocales;
        final locales2 = languageService.supportedLocales;

        // Should return same reference (const list)
        expect(identical(locales1, locales2), isTrue);
      });
    });

    group('Language names', () {
      test('contains Polish language name', () {
        expect(languageService.languageNames['pl'], equals('Polski'));
      });

      test('contains English language name', () {
        expect(languageService.languageNames['en'], equals('English'));
      });

      test('languageNames has exactly 2 entries', () {
        expect(languageService.languageNames.length, equals(2));
      });

      test('languageNames keys match supportedLocales', () {
        final localeLanguageCodes = languageService.supportedLocales
            .map((locale) => locale.languageCode)
            .toSet();
        final nameKeys = languageService.languageNames.keys.toSet();

        expect(localeLanguageCodes, equals(nameKeys));
      });
    });

    group('Locale properties', () {
      test('Polish locale has correct language code', () {
        const polishLocale = Locale('pl');
        expect(polishLocale.languageCode, equals('pl'));
      });

      test('English locale has correct language code', () {
        const englishLocale = Locale('en');
        expect(englishLocale.languageCode, equals('en'));
      });
    });

    group('ChangeNotifier behavior', () {
      test('extends ChangeNotifier', () {
        expect(languageService, isA<ChangeNotifier>());
      });

      test('can add listeners', () {
        var notified = false;
        languageService.addListener(() {
          notified = true;
        });

        // Listeners can be added without error
        expect(notified, isFalse);
      });
    });
  });
}

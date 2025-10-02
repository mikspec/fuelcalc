// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Kalkulator Paliwa';

  @override
  String get homeTitle => 'Kalkulator Paliwa';

  @override
  String get vehicles => 'Pojazdy';

  @override
  String get addVehicle => 'Dodaj Pojazd';

  @override
  String get backup => 'Backup';

  @override
  String get language => 'Język';

  @override
  String get deleteVehicle => 'Usuń pojazd';

  @override
  String deleteVehicleConfirm(String vehicleName) {
    return 'Czy na pewno chcesz usunąć pojazd \"$vehicleName\"?\n\nWszystkie tankowania i wydatki zostaną trwale usunięte.';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get vehicleDeleted => 'Pojazd został usunięty';

  @override
  String errorDeleteVehicle(String error) {
    return 'Błąd usuwania pojazdu: $error';
  }

  @override
  String errorLoadingVehicles(String error) {
    return 'Błąd ładowania pojazdów: $error';
  }

  @override
  String get viewDetails => 'Zobacz Szczegóły';

  @override
  String get edit => 'Edytuj';

  @override
  String get noVehicles =>
      'Nie dodano jeszcze żadnych pojazdów.\nDotknij przycisk + aby dodać pierwszy pojazd.';

  @override
  String get refuels => 'Tankowania';

  @override
  String get statistics => 'Statystyki';

  @override
  String get addRefuel => 'Dodaj tankowanie';

  @override
  String get refuelForm => 'Formularz Tankowania';

  @override
  String get editRefuel => 'Edytuj Tankowanie';

  @override
  String get amount => 'Ilość';

  @override
  String get cost => 'Koszt';

  @override
  String get date => 'Data';

  @override
  String get time => 'Godzina';

  @override
  String get odometer => 'Przebieg';

  @override
  String get fuelType => 'Typ Paliwa';

  @override
  String get gasoline => 'Benzyna';

  @override
  String get diesel => 'Diesel';

  @override
  String get lpg => 'LPG';

  @override
  String get refuelType => 'Typ tankowania';

  @override
  String get fullTank => 'Pełny bak';

  @override
  String get partial => 'Częściowe';

  @override
  String get stationRating => 'Ocena stacji';

  @override
  String get location => 'Lokalizacja';

  @override
  String get getLocation => 'Pobierz';

  @override
  String get notes => 'Notatki';

  @override
  String get save => 'Zapisz';

  @override
  String errorSaving(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String get pleaseEnterAmount => 'Proszę wprowadzić ilość';

  @override
  String get pleaseEnterCost => 'Proszę wprowadzić koszt';

  @override
  String get pleaseEnterOdometer => 'Proszę wprowadzić przebieg';

  @override
  String statisticsTitle(String vehicleName) {
    return 'Statystyki - $vehicleName';
  }

  @override
  String get dataRange => 'Zakres danych';

  @override
  String get last5 => 'Ostatnie 5';

  @override
  String get last10 => 'Ostatnie 10';

  @override
  String get all => 'Wszystkie';

  @override
  String get summary => 'Podsumowanie';

  @override
  String get fuel => 'Paliwo:';

  @override
  String get expenses => 'Wydatki:';

  @override
  String get total => 'Razem:';

  @override
  String get costPer100km => 'Koszt na 100 km:';

  @override
  String get refuelChart => 'Wykres Tankowań';

  @override
  String get consumptionChart => 'Wykres Spalania';

  @override
  String get noDataToDisplay => 'Brak danych do wyświetlenia';

  @override
  String get noConsumptionData => 'Brak danych o spalaniu';

  @override
  String errorLoadingStatistics(String error) {
    return 'Błąd ładowania statystyk: $error';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get exportBackup => 'Eksportuj Backup';

  @override
  String get importBackup => 'Importuj Backup';

  @override
  String get exportSqlite => 'Eksportuj SQLite';

  @override
  String get importSqlite => 'Importuj SQLite';

  @override
  String get backupDownloaded => 'Backup został pobrany';

  @override
  String get dataImportedSuccessfully => 'Dane zostały zaimportowane pomyślnie';

  @override
  String get confirmImport => 'Potwierdź import';

  @override
  String get importWarning =>
      'Import danych z backup może nadpisać istniejące dane. Czy chcesz kontynuować?';

  @override
  String get import => 'Importuj';

  @override
  String errorExport(String error) {
    return 'Błąd eksportu: $error';
  }

  @override
  String errorImport(String error) {
    return 'Błąd importu: $error';
  }

  @override
  String get vehicleName => 'Nazwa Pojazdu';

  @override
  String get vehicleAlias => 'Alias Pojazdu';

  @override
  String get pleaseEnterVehicleName => 'Proszę wprowadzić nazwę pojazdu';

  @override
  String get addVehicleTitle => 'Dodaj Pojazd';

  @override
  String get editVehicleTitle => 'Edytuj Pojazd';

  @override
  String get rating => 'Ocena: ';

  @override
  String get deleteRefuel => 'Usuń tankowanie';

  @override
  String deleteRefuelConfirm(String date) {
    return 'Czy na pewno chcesz usunąć tankowanie z $date?';
  }

  @override
  String get refuelDeleted => 'Tankowanie zostało usunięte';

  @override
  String errorDeleteRefuel(String error) {
    return 'Błąd usuwania tankowania: $error';
  }

  @override
  String refuelsTitle(String vehicleName) {
    return 'Tankowania - $vehicleName';
  }

  @override
  String errorLoadingRefuels(String error) {
    return 'Błąd ładowania tankowań: $error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Błąd ładowania danych: $error';
  }

  @override
  String get recentRefuels => 'Ostatnie tankowania';

  @override
  String get viewAll => 'Zobacz wszystkie';

  @override
  String get noRefuels => 'Brak tankowań';

  @override
  String get recentExpenses => 'Ostatnie wydatki';

  @override
  String get noExpenses => 'Brak wydatków';

  @override
  String get quickStats => 'Szybkie statystyki';

  @override
  String get totalRefuels => 'Łączna liczba tankowań';

  @override
  String get averageConsumption => 'Średnie spalanie';

  @override
  String get totalDistance => 'Łączny dystans';

  @override
  String get lastRefuel => 'Ostatnie tankowanie';

  @override
  String get description => 'Opis';

  @override
  String get initialMileage => 'Początkowy przebieg (km)';

  @override
  String get tankCapacity => 'Pojemność baku (l)';

  @override
  String get refuelAdded => 'Tankowanie dodane';

  @override
  String get refuelUpdated => 'Tankowanie zaktualizowane';

  @override
  String get backupManagement => 'Zarządzanie Backup';

  @override
  String get exportData => 'Eksport danych';

  @override
  String get importData => 'Import danych';

  @override
  String get exportDataDescription =>
      'Utwórz kopię zapasową wszystkich danych aplikacji (samochody, tankowania, wydatki).';

  @override
  String get importDataDescription =>
      'Wczytaj dane z pliku backup. Uwaga: może to nadpisać istniejące dane.';

  @override
  String get exportDataButton => 'Eksportuj dane';

  @override
  String get importDataButton => 'Importuj dane';

  @override
  String get exportSqliteDatabase => 'Eksport bazy SQLite';

  @override
  String get importSqliteDatabase => 'Import bazy SQLite';

  @override
  String get exportSqliteDescription =>
      'Eksportuj oryginalny plik bazy danych SQLite. Można go otworzyć w innych aplikacjach SQLite.';

  @override
  String get importSqliteDescription =>
      'Wczytaj plik bazy SQLite. UWAGA: zastąpi to całą istniejącą bazę danych!';

  @override
  String get exportSqliteButton => 'Eksportuj SQLite';

  @override
  String get importSqliteButton => 'Importuj SQLite';

  @override
  String get information => 'Informacje';

  @override
  String get backupInformation =>
      '• Backup JSON: uniwersalny format, działa na wszystkich platformach\n• Backup SQLite: oryginalny plik bazy, tylko na desktop/mobile\n• Oba formaty zawierają wszystkie dane\n• SQLite można otworzyć w zewnętrznych narzędziach\n• Import może nadpisać istniejące dane';

  @override
  String get sqliteExportNotAvailableOnWeb =>
      'Eksport SQLite nie jest dostępny na web';

  @override
  String get sqliteImportNotAvailableOnWeb =>
      'Import SQLite nie jest dostępny na web';

  @override
  String get sqliteDatabaseExported => 'Baza SQLite została wyeksportowana';

  @override
  String get sqliteDatabaseImportedSuccessfully =>
      'Baza SQLite została zaimportowana pomyślnie';

  @override
  String get confirmImportMessage =>
      'Import danych z backup może nadpisać istniejące dane. Czy chcesz kontynuować?';

  @override
  String get confirmSqliteImport => 'Potwierdź import SQLite';

  @override
  String get confirmSqliteImportMessage =>
      'Import pliku SQLite zastąpi całą istniejącą bazę danych. Ta operacja nie może być cofnięta. Czy chcesz kontynuować?';

  @override
  String get replaceDatabase => 'ZASTĄP BAZĘ';

  @override
  String get backupJson => 'Backup JSON';

  @override
  String get automaticDownloadFailed =>
      'Automatyczne pobieranie nie powiodło się. Skopiuj dane poniżej:';

  @override
  String get close => 'Zamknij';

  @override
  String get fileDownloadInDevelopment =>
      'Pobieranie plików na tej platformie w rozwoju';

  @override
  String get exportInDevelopment => 'Eksport na mobile - funkcja w rozwoju';

  @override
  String get expenseAdded => 'Wydatek dodany';

  @override
  String get expenseUpdated => 'Wydatek zaktualizowany';

  @override
  String get addExpense => 'Dodaj wydatek';

  @override
  String get editExpense => 'Edytuj wydatek';

  @override
  String get basicData => 'Podstawowe dane';

  @override
  String get titleRequired => 'Tytuł jest wymagany';

  @override
  String get required => 'Wymagane';

  @override
  String get invalidCost => 'Nieprawidłowy koszt';

  @override
  String get category => 'Kategoria';

  @override
  String get dateAndDetails => 'Data i szczegóły';

  @override
  String get serviceRating => 'Ocena usługi';

  @override
  String get updateExpense => 'Zaktualizuj wydatek';

  @override
  String get deleteExpense => 'Usuń wydatek';

  @override
  String confirmDeleteExpense(String title) {
    return 'Czy na pewno chcesz usunąć wydatek \\\"$title\\\"?';
  }

  @override
  String get expenseDeleted => 'Wydatek został usunięty';

  @override
  String get addFirstExpense =>
      'Dodaj pierwszy wydatek używając przycisku poniżej';

  @override
  String get totalCost => 'Łączny koszt';

  @override
  String get numberOfExpenses => 'Liczba wydatków';

  @override
  String get addExpenseTooltip => 'Dodaj wydatek';

  @override
  String get title => 'Tytuł';

  @override
  String get vehicleAdded => 'Pojazd dodany';

  @override
  String get vehicleUpdated => 'Pojazd zaktualizowany';

  @override
  String get basicInformation => 'Podstawowe informacje';

  @override
  String get technicalParameters => 'Parametry techniczne';

  @override
  String get enterValidMileage => 'Wprowadź prawidłowy przebieg';

  @override
  String get enterValidCapacity => 'Wprowadź prawidłową pojemność';

  @override
  String get updateVehicle => 'Zaktualizuj pojazd';

  @override
  String get addVehicleButton => 'Dodaj pojazd';

  @override
  String exportError(String error) {
    return 'Błąd eksportu: $error';
  }

  @override
  String importError(String error) {
    return 'Błąd importu: $error';
  }

  @override
  String get invalidBackupFormat =>
      'Nieprawidłowy format pliku backup. Sprawdź czy plik zawiera prawidłowy obiekt JSON z polami version, timestamp i cars.';

  @override
  String sqliteExportError(String error) {
    return 'Błąd eksportu SQLite: $error';
  }

  @override
  String sqliteImportError(String error) {
    return 'Błąd importu SQLite: $error';
  }

  @override
  String get invalidSqliteFormat => 'Nieprawidłowy format pliku SQLite';

  @override
  String fileDownloaded(String fileName) {
    return 'Plik $fileName został pobrany';
  }

  @override
  String get lastRefuels => 'Ostatnie 10 tankowań';

  @override
  String get avgConsumption => 'Średnie spalanie';

  @override
  String get avgPrice => 'Średnia cena';

  @override
  String get distance => 'Dystans';

  @override
  String get fuelCosts => 'Koszty paliwa';

  @override
  String saveError(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String get titleHint => 'np. Wymiana oleju';

  @override
  String get descriptionLabel => 'Opis/Notatki';

  @override
  String get descriptionHint => 'Dodatkowe informacje o wydatku...';

  @override
  String get expenseTypeOther => 'Inne';

  @override
  String get expenseTypeBattery => 'Akumulator';

  @override
  String get expenseTypeRepair => 'Naprawa';

  @override
  String get expenseTypeTowing => 'Laweta';

  @override
  String get expenseTypeInsurance => 'Ubezpieczenie';

  @override
  String get expenseTypeInspection => 'Przegląd';

  @override
  String get expenseTypeUnknown => 'Nieznane';
}

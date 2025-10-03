// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fuel Calculator';

  @override
  String get homeTitle => 'Fuel Calculator';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get backup => 'Backup';

  @override
  String get language => 'Language';

  @override
  String get deleteVehicle => 'Delete Vehicle';

  @override
  String deleteVehicleConfirm(String vehicleName) {
    return 'Are you sure you want to delete vehicle \"$vehicleName\"?\n\nAll refuels and expenses will be permanently deleted.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get vehicleDeleted => 'Vehicle has been deleted';

  @override
  String errorDeleteVehicle(String error) {
    return 'Error deleting vehicle: $error';
  }

  @override
  String errorLoadingVehicles(String error) {
    return 'Error loading vehicles: $error';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get edit => 'Edit';

  @override
  String get noVehicles =>
      'No vehicles added yet.\nTap the + button to add your first vehicle.';

  @override
  String get refuels => 'Refuels';

  @override
  String get statistics => 'Statistics';

  @override
  String get addRefuel => 'Add refuel';

  @override
  String get refuelForm => 'Refuel Form';

  @override
  String get editRefuel => 'Edit Refuel';

  @override
  String get amount => 'Amount';

  @override
  String get cost => 'Cost';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get odometer => 'Odometer';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get gasoline => 'Gasoline';

  @override
  String get diesel => 'Diesel';

  @override
  String get lpg => 'LPG';

  @override
  String get refuelType => 'Refuel Type';

  @override
  String get fullTank => 'Full Tank';

  @override
  String get partial => 'Partial';

  @override
  String get stationRating => 'Station Rating';

  @override
  String get location => 'Location';

  @override
  String get getLocation => 'Get';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get pleaseEnterCost => 'Please enter cost';

  @override
  String get pleaseEnterOdometer => 'Please enter odometer reading';

  @override
  String statisticsTitle(String vehicleName) {
    return 'Statistics - $vehicleName';
  }

  @override
  String get dataRange => 'Data Range';

  @override
  String get last5 => 'Last 5';

  @override
  String get last10 => 'Last 10';

  @override
  String get all => 'All';

  @override
  String get summary => 'Summary';

  @override
  String get fuel => 'Fuel:';

  @override
  String get expenses => 'Expenses:';

  @override
  String get total => 'Total:';

  @override
  String get costPer100km => 'Cost per 100 km';

  @override
  String get refuelChart => 'Refuel Chart';

  @override
  String get consumptionChart => 'Consumption Chart';

  @override
  String get noDataToDisplay => 'No data to display';

  @override
  String get noConsumptionData => 'No consumption data';

  @override
  String errorLoadingStatistics(String error) {
    return 'Error loading statistics: $error';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get exportSqlite => 'Export SQLite';

  @override
  String get importSqlite => 'Import SQLite';

  @override
  String get backupDownloaded => 'Backup has been downloaded';

  @override
  String get dataImportedSuccessfully => 'Data imported successfully';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get importWarning =>
      'Importing backup data may overwrite existing data. Do you want to continue?';

  @override
  String get import => 'Import';

  @override
  String errorExport(String error) {
    return 'Export error: $error';
  }

  @override
  String errorImport(String error) {
    return 'Import error: $error';
  }

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get vehicleAlias => 'Vehicle Alias';

  @override
  String get pleaseEnterVehicleName => 'Please enter vehicle name';

  @override
  String get addVehicleTitle => 'Add Vehicle';

  @override
  String get editVehicleTitle => 'Edit Vehicle';

  @override
  String get rating => 'Rating: ';

  @override
  String get deleteRefuel => 'Delete Refuel';

  @override
  String deleteRefuelConfirm(String date) {
    return 'Are you sure you want to delete refuel from $date?';
  }

  @override
  String get refuelDeleted => 'Refuel has been deleted';

  @override
  String errorDeleteRefuel(String error) {
    return 'Error deleting refuel: $error';
  }

  @override
  String refuelsTitle(String vehicleName) {
    return 'Refuels - $vehicleName';
  }

  @override
  String errorLoadingRefuels(String error) {
    return 'Error loading refuels: $error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get recentRefuels => 'Recent Refuels';

  @override
  String get viewAll => 'View All';

  @override
  String get noRefuels => 'No refuels';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get noExpenses => 'No Expenses';

  @override
  String get quickStats => 'Quick Statistics';

  @override
  String get totalRefuels => 'Total refuels';

  @override
  String get averageConsumption => 'Average consumption';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get lastRefuel => 'Last refuel';

  @override
  String get description => 'Description';

  @override
  String get initialMileage => 'Initial mileage (km)';

  @override
  String get tankCapacity => 'Tank capacity (l)';

  @override
  String get refuelAdded => 'Refuel added';

  @override
  String get refuelUpdated => 'Refuel updated';

  @override
  String get backupManagement => 'Backup Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportDataDescription =>
      'Create a backup of all application data (cars, refuels, expenses).';

  @override
  String get importDataDescription =>
      'Load data from backup file. Warning: this may overwrite existing data.';

  @override
  String get exportDataButton => 'Export Data';

  @override
  String get importDataButton => 'Import Data';

  @override
  String get exportSqliteDatabase => 'Export SQLite Database';

  @override
  String get importSqliteDatabase => 'Import SQLite Database';

  @override
  String get exportSqliteDescription =>
      'Export the original SQLite database file. Can be opened in other SQLite applications.';

  @override
  String get importSqliteDescription =>
      'Load SQLite database file. WARNING: this will replace the entire existing database!';

  @override
  String get exportSqliteButton => 'Export SQLite';

  @override
  String get importSqliteButton => 'Import SQLite';

  @override
  String get information => 'Information';

  @override
  String get backupInformation =>
      '• JSON Backup: universal format, works on all platforms\n• SQLite Backup: original database file, desktop/mobile only\n• Both formats contain all data\n• SQLite can be opened in external tools\n• Import may overwrite existing data';

  @override
  String get sqliteExportNotAvailableOnWeb =>
      'SQLite export is not available on web';

  @override
  String get sqliteImportNotAvailableOnWeb =>
      'SQLite import is not available on web';

  @override
  String get sqliteDatabaseExported => 'SQLite database exported';

  @override
  String get sqliteDatabaseImportedSuccessfully =>
      'SQLite database imported successfully';

  @override
  String get confirmImportMessage =>
      'Importing data from backup may overwrite existing data. Do you want to continue?';

  @override
  String get confirmSqliteImport => 'Confirm SQLite Import';

  @override
  String get confirmSqliteImportMessage =>
      'Importing SQLite file will replace the entire existing database. This operation cannot be undone. Do you want to continue?';

  @override
  String get replaceDatabase => 'REPLACE DATABASE';

  @override
  String get backupJson => 'Backup JSON';

  @override
  String get automaticDownloadFailed =>
      'Automatic download failed. Copy the data below:';

  @override
  String get close => 'Close';

  @override
  String get fileDownloadInDevelopment =>
      'File download on this platform is in development';

  @override
  String get exportInDevelopment => 'Export on mobile - feature in development';

  @override
  String get expenseAdded => 'Expense added';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get basicData => 'Basic Data';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get required => 'Required';

  @override
  String get invalidCost => 'Invalid cost';

  @override
  String get category => 'Category';

  @override
  String get dateAndDetails => 'Date and Details';

  @override
  String get serviceRating => 'Service Rating';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String confirmDeleteExpense(String title) {
    return 'Are you sure you want to delete expense \"$title\"?';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get addFirstExpense => 'Add your first expense using the button below';

  @override
  String get totalCost => 'Total cost';

  @override
  String get numberOfExpenses => 'Number of expenses';

  @override
  String get addExpenseTooltip => 'Add Expense';

  @override
  String get title => 'Title';

  @override
  String get vehicleAdded => 'Vehicle added';

  @override
  String get vehicleUpdated => 'Vehicle updated';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get technicalParameters => 'Technical Parameters';

  @override
  String get enterValidMileage => 'Enter valid mileage';

  @override
  String get enterValidCapacity => 'Enter valid capacity';

  @override
  String get updateVehicle => 'Update Vehicle';

  @override
  String get addVehicleButton => 'Add Vehicle';

  @override
  String exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String importError(String error) {
    return 'Import error: $error';
  }

  @override
  String get invalidBackupFormat =>
      'Invalid backup file format. Check if the file contains a valid JSON object with version, timestamp and cars fields.';

  @override
  String sqliteExportError(String error) {
    return 'SQLite export error: $error';
  }

  @override
  String sqliteImportError(String error) {
    return 'SQLite import error: $error';
  }

  @override
  String get invalidSqliteFormat => 'Invalid SQLite file format';

  @override
  String fileDownloaded(String fileName) {
    return 'File $fileName has been downloaded';
  }

  @override
  String get lastRefuels => 'Last 10 refuels';

  @override
  String get avgConsumption => 'Average consumption';

  @override
  String get avgPrice => 'Average price';

  @override
  String get distance => 'Distance';

  @override
  String get fuelCosts => 'Fuel costs';

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get titleHint => 'e.g. Oil change';

  @override
  String get descriptionLabel => 'Description/Notes';

  @override
  String get descriptionHint => 'Additional information about the expense...';

  @override
  String get expenseTypeOther => 'Other';

  @override
  String get expenseTypeBattery => 'Battery';

  @override
  String get expenseTypeRepair => 'Repair';

  @override
  String get expenseTypeTowing => 'Towing';

  @override
  String get expenseTypeInsurance => 'Insurance';

  @override
  String get expenseTypeInspection => 'Inspection';

  @override
  String get expenseTypeUnknown => 'Unknown';

  @override
  String get refuelStatistics => 'Refuel Statistics';

  @override
  String get expenseStatistics => 'Expense Statistics';

  @override
  String get numberOfRefuels => 'Number of refuels';

  @override
  String get totalFuelAmount => 'Total fuel amount';

  @override
  String get averagePricePerLiter => 'Average price per liter';

  @override
  String get averageCost => 'Average cost';

  @override
  String get invalidVolume => 'Invalid volume';

  @override
  String get invalidOdometerReading => 'Invalid odometer reading';

  @override
  String errorLoadingLastOdometer(String error) {
    return 'Error loading last odometer reading: $error';
  }

  @override
  String errorLoadingLocation(String error) {
    return 'Error loading location: $error';
  }

  @override
  String errorCalculatingDistance(String error) {
    return 'Error calculating distance: $error';
  }

  @override
  String get distanceFromLast => 'Distance from last';

  @override
  String lastOdometer(String reading) {
    return 'Last: $reading km';
  }

  @override
  String get additionalInfoHint => 'Additional information...';

  @override
  String get loadingLocation => 'Loading location...';

  @override
  String locationCoordinates(String latitude, String longitude) {
    return 'Location: $latitude, $longitude';
  }

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get updateRefuel => 'Update Refuel';

  @override
  String get addRefuelButton => 'Add Refuel';

  @override
  String errorLoadingExpenses(String error) {
    return 'Error loading expenses: $error';
  }

  @override
  String errorDeletingExpense(String error) {
    return 'Error deleting expense: $error';
  }

  @override
  String get dateLabel => 'Date:';

  @override
  String get ratingLabel => 'Rating:';

  @override
  String get noDescription => 'No description';

  @override
  String get noRefuelsYet => 'No refuels yet';

  @override
  String get addFirstRefuel => 'Add your first refuel using the button below';

  @override
  String get pricePerLiter => 'Price per liter';

  @override
  String get consumption => 'Consumption';

  @override
  String get odometerReading => 'Odometer reading';

  @override
  String get gpsLocation => 'GPS Location';

  @override
  String get addRefuelTooltip => 'Add refuel';
}

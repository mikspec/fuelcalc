import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Fuel Calculator'**
  String get appTitle;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Fuel Calculator'**
  String get homeTitle;

  /// Vehicles section title
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// Add vehicle button text
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// Backup menu item
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Language menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Delete vehicle dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicle;

  /// Delete vehicle confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete vehicle \"{vehicleName}\"?\n\nAll refuels and expenses will be permanently deleted.'**
  String deleteVehicleConfirm(String vehicleName);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Vehicle deleted success message
  ///
  /// In en, this message translates to:
  /// **'Vehicle has been deleted'**
  String get vehicleDeleted;

  /// Error deleting vehicle message
  ///
  /// In en, this message translates to:
  /// **'Error deleting vehicle: {error}'**
  String errorDeleteVehicle(String error);

  /// Error loading vehicles message
  ///
  /// In en, this message translates to:
  /// **'Error loading vehicles: {error}'**
  String errorLoadingVehicles(String error);

  /// View vehicle details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Edit menu item text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Empty vehicles list message
  ///
  /// In en, this message translates to:
  /// **'No vehicles added yet.\nTap the + button to add your first vehicle.'**
  String get noVehicles;

  /// Refuels tab title
  ///
  /// In en, this message translates to:
  /// **'Refuels'**
  String get refuels;

  /// Statistics tooltip
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Add refuel tooltip
  ///
  /// In en, this message translates to:
  /// **'Add refuel'**
  String get addRefuel;

  /// Refuel form screen title
  ///
  /// In en, this message translates to:
  /// **'Refuel Form'**
  String get refuelForm;

  /// Edit refuel screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Refuel'**
  String get editRefuel;

  /// Fuel amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Cost field label
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time field label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Odometer field label
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometer;

  /// Fuel type field label
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// Gasoline fuel type
  ///
  /// In en, this message translates to:
  /// **'Gasoline'**
  String get gasoline;

  /// Diesel fuel type
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// LPG fuel type
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get lpg;

  /// Refuel type field label
  ///
  /// In en, this message translates to:
  /// **'Refuel Type'**
  String get refuelType;

  /// Full tank refuel type
  ///
  /// In en, this message translates to:
  /// **'Full Tank'**
  String get fullTank;

  /// Partial refuel type
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// Station rating field label
  ///
  /// In en, this message translates to:
  /// **'Station Rating'**
  String get stationRating;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Get location button text
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get getLocation;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Error saving message
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// Amount validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// Cost validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter cost'**
  String get pleaseEnterCost;

  /// Odometer validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter odometer reading'**
  String get pleaseEnterOdometer;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics - {vehicleName}'**
  String statisticsTitle(String vehicleName);

  /// Data range section title
  ///
  /// In en, this message translates to:
  /// **'Data Range'**
  String get dataRange;

  /// Last 5 items range option
  ///
  /// In en, this message translates to:
  /// **'Last 5'**
  String get last5;

  /// Last 10 items range option
  ///
  /// In en, this message translates to:
  /// **'Last 10'**
  String get last10;

  /// All items range option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Summary section title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Fuel costs label
  ///
  /// In en, this message translates to:
  /// **'Fuel:'**
  String get fuel;

  /// Expenses costs label
  ///
  /// In en, this message translates to:
  /// **'Expenses:'**
  String get expenses;

  /// Total costs label
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// Cost per 100 km label
  ///
  /// In en, this message translates to:
  /// **'Cost per 100 km'**
  String get costPer100km;

  /// Refuel chart section title
  ///
  /// In en, this message translates to:
  /// **'Refuel Chart'**
  String get refuelChart;

  /// Consumption chart section title
  ///
  /// In en, this message translates to:
  /// **'Consumption Chart'**
  String get consumptionChart;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noDataToDisplay;

  /// No consumption data message
  ///
  /// In en, this message translates to:
  /// **'No consumption data'**
  String get noConsumptionData;

  /// Error loading statistics message
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String errorLoadingStatistics(String error);

  /// Backup screen title
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// Export backup button text
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// Import backup button text
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// Export SQLite button text
  ///
  /// In en, this message translates to:
  /// **'Export SQLite'**
  String get exportSqlite;

  /// Import SQLite button text
  ///
  /// In en, this message translates to:
  /// **'Import SQLite'**
  String get importSqlite;

  /// Backup downloaded success message
  ///
  /// In en, this message translates to:
  /// **'Backup has been downloaded'**
  String get backupDownloaded;

  /// Data import success message
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImportedSuccessfully;

  /// Confirm import dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// Import warning message
  ///
  /// In en, this message translates to:
  /// **'Importing backup data may overwrite existing data. Do you want to continue?'**
  String get importWarning;

  /// Import button text
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Export error message
  ///
  /// In en, this message translates to:
  /// **'Export error: {error}'**
  String errorExport(String error);

  /// Import error message
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String errorImport(String error);

  /// Vehicle name field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicleName;

  /// Vehicle alias field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Alias'**
  String get vehicleAlias;

  /// Vehicle name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle name'**
  String get pleaseEnterVehicleName;

  /// Add vehicle screen title
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleTitle;

  /// Edit vehicle screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicleTitle;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating: '**
  String get rating;

  /// Delete refuel dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Refuel'**
  String get deleteRefuel;

  /// Delete refuel confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete refuel from {date}?'**
  String deleteRefuelConfirm(String date);

  /// Refuel deleted success message
  ///
  /// In en, this message translates to:
  /// **'Refuel has been deleted'**
  String get refuelDeleted;

  /// Error deleting refuel message
  ///
  /// In en, this message translates to:
  /// **'Error deleting refuel: {error}'**
  String errorDeleteRefuel(String error);

  /// Refuels screen title
  ///
  /// In en, this message translates to:
  /// **'Refuels - {vehicleName}'**
  String refuelsTitle(String vehicleName);

  /// Error loading refuels message
  ///
  /// In en, this message translates to:
  /// **'Error loading refuels: {error}'**
  String errorLoadingRefuels(String error);

  /// Error loading data message
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// Recent refuels section title
  ///
  /// In en, this message translates to:
  /// **'Recent Refuels'**
  String get recentRefuels;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No refuels message
  ///
  /// In en, this message translates to:
  /// **'No refuels'**
  String get noRefuels;

  /// Recent expenses section title
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No expenses message
  ///
  /// In en, this message translates to:
  /// **'No Expenses'**
  String get noExpenses;

  /// Quick statistics section title
  ///
  /// In en, this message translates to:
  /// **'Quick Statistics'**
  String get quickStats;

  /// Total refuels label
  ///
  /// In en, this message translates to:
  /// **'Total refuels'**
  String get totalRefuels;

  /// Average consumption label
  ///
  /// In en, this message translates to:
  /// **'Average consumption'**
  String get averageConsumption;

  /// Total distance label
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get totalDistance;

  /// Last refuel label
  ///
  /// In en, this message translates to:
  /// **'Last refuel'**
  String get lastRefuel;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Initial mileage field label
  ///
  /// In en, this message translates to:
  /// **'Initial mileage (km)'**
  String get initialMileage;

  /// Tank capacity field label
  ///
  /// In en, this message translates to:
  /// **'Tank capacity (l)'**
  String get tankCapacity;

  /// Refuel added success message
  ///
  /// In en, this message translates to:
  /// **'Refuel added'**
  String get refuelAdded;

  /// Refuel updated success message
  ///
  /// In en, this message translates to:
  /// **'Refuel updated'**
  String get refuelUpdated;

  /// Backup screen title
  ///
  /// In en, this message translates to:
  /// **'Backup Management'**
  String get backupManagement;

  /// Export data section title
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Import data section title
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Export data section description
  ///
  /// In en, this message translates to:
  /// **'Create a backup of all application data (cars, refuels, expenses).'**
  String get exportDataDescription;

  /// Import data section description
  ///
  /// In en, this message translates to:
  /// **'Load data from backup file. Warning: this may overwrite existing data.'**
  String get importDataDescription;

  /// Export data button text
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataButton;

  /// Import data button text
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importDataButton;

  /// Export SQLite section title
  ///
  /// In en, this message translates to:
  /// **'Export SQLite Database'**
  String get exportSqliteDatabase;

  /// Import SQLite section title
  ///
  /// In en, this message translates to:
  /// **'Import SQLite Database'**
  String get importSqliteDatabase;

  /// Export SQLite section description
  ///
  /// In en, this message translates to:
  /// **'Export the original SQLite database file. Can be opened in other SQLite applications.'**
  String get exportSqliteDescription;

  /// Import SQLite section description
  ///
  /// In en, this message translates to:
  /// **'Load SQLite database file. WARNING: this will replace the entire existing database!'**
  String get importSqliteDescription;

  /// Export SQLite button text
  ///
  /// In en, this message translates to:
  /// **'Export SQLite'**
  String get exportSqliteButton;

  /// Import SQLite button text
  ///
  /// In en, this message translates to:
  /// **'Import SQLite'**
  String get importSqliteButton;

  /// Information section title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Backup information text
  ///
  /// In en, this message translates to:
  /// **'• JSON Backup: universal format, works on all platforms\n• SQLite Backup: original database file, desktop/mobile only\n• Both formats contain all data\n• SQLite can be opened in external tools\n• Import may overwrite existing data'**
  String get backupInformation;

  /// SQLite export not available on web message
  ///
  /// In en, this message translates to:
  /// **'SQLite export is not available on web'**
  String get sqliteExportNotAvailableOnWeb;

  /// SQLite import not available on web message
  ///
  /// In en, this message translates to:
  /// **'SQLite import is not available on web'**
  String get sqliteImportNotAvailableOnWeb;

  /// SQLite database exported message
  ///
  /// In en, this message translates to:
  /// **'SQLite database exported'**
  String get sqliteDatabaseExported;

  /// SQLite database import success message
  ///
  /// In en, this message translates to:
  /// **'SQLite database imported successfully'**
  String get sqliteDatabaseImportedSuccessfully;

  /// Confirm import dialog message
  ///
  /// In en, this message translates to:
  /// **'Importing data from backup may overwrite existing data. Do you want to continue?'**
  String get confirmImportMessage;

  /// Confirm SQLite import dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm SQLite Import'**
  String get confirmSqliteImport;

  /// Confirm SQLite import dialog message
  ///
  /// In en, this message translates to:
  /// **'Importing SQLite file will replace the entire existing database. This operation cannot be undone. Do you want to continue?'**
  String get confirmSqliteImportMessage;

  /// Replace database button text
  ///
  /// In en, this message translates to:
  /// **'REPLACE DATABASE'**
  String get replaceDatabase;

  /// Backup JSON dialog title
  ///
  /// In en, this message translates to:
  /// **'Backup JSON'**
  String get backupJson;

  /// Automatic download failed message
  ///
  /// In en, this message translates to:
  /// **'Automatic download failed. Copy the data below:'**
  String get automaticDownloadFailed;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// File download in development message
  ///
  /// In en, this message translates to:
  /// **'File download on this platform is in development'**
  String get fileDownloadInDevelopment;

  /// Export in development message
  ///
  /// In en, this message translates to:
  /// **'Export on mobile - feature in development'**
  String get exportInDevelopment;

  /// Expense added success message
  ///
  /// In en, this message translates to:
  /// **'Expense added'**
  String get expenseAdded;

  /// Expense updated success message
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// Add expense tooltip
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// Edit expense title
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// Basic data section title
  ///
  /// In en, this message translates to:
  /// **'Basic Data'**
  String get basicData;

  /// Title required validation message
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Required validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Invalid cost validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid cost'**
  String get invalidCost;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Date and details section title
  ///
  /// In en, this message translates to:
  /// **'Date and Details'**
  String get dateAndDetails;

  /// Service rating section title
  ///
  /// In en, this message translates to:
  /// **'Service Rating'**
  String get serviceRating;

  /// Update expense button text
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// Delete expense dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// Confirm delete expense message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete expense \"{title}\"?'**
  String confirmDeleteExpense(String title);

  /// Expense deleted success message
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// Add first expense message
  ///
  /// In en, this message translates to:
  /// **'Add your first expense using the button below'**
  String get addFirstExpense;

  /// Total cost label
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalCost;

  /// Number of expenses label
  ///
  /// In en, this message translates to:
  /// **'Number of expenses'**
  String get numberOfExpenses;

  /// Add expense tooltip
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseTooltip;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Vehicle added success message
  ///
  /// In en, this message translates to:
  /// **'Vehicle added'**
  String get vehicleAdded;

  /// Vehicle updated success message
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated'**
  String get vehicleUpdated;

  /// Basic information section title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Technical parameters section title
  ///
  /// In en, this message translates to:
  /// **'Technical Parameters'**
  String get technicalParameters;

  /// Valid mileage validation message
  ///
  /// In en, this message translates to:
  /// **'Enter valid mileage'**
  String get enterValidMileage;

  /// Valid capacity validation message
  ///
  /// In en, this message translates to:
  /// **'Enter valid capacity'**
  String get enterValidCapacity;

  /// Update vehicle button text
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updateVehicle;

  /// Add vehicle button text
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleButton;

  /// Export error message
  ///
  /// In en, this message translates to:
  /// **'Export error: {error}'**
  String exportError(String error);

  /// Import error message
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String importError(String error);

  /// Invalid backup format error message
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file format. Check if the file contains a valid JSON object with version, timestamp and cars fields.'**
  String get invalidBackupFormat;

  /// SQLite export error message
  ///
  /// In en, this message translates to:
  /// **'SQLite export error: {error}'**
  String sqliteExportError(String error);

  /// SQLite import error message
  ///
  /// In en, this message translates to:
  /// **'SQLite import error: {error}'**
  String sqliteImportError(String error);

  /// Invalid SQLite format error message
  ///
  /// In en, this message translates to:
  /// **'Invalid SQLite file format'**
  String get invalidSqliteFormat;

  /// File downloaded success message
  ///
  /// In en, this message translates to:
  /// **'File {fileName} has been downloaded'**
  String fileDownloaded(String fileName);

  /// Recent refuels card title
  ///
  /// In en, this message translates to:
  /// **'Last 10 refuels'**
  String get lastRefuels;

  /// Average consumption label
  ///
  /// In en, this message translates to:
  /// **'Average consumption'**
  String get avgConsumption;

  /// Average price label
  ///
  /// In en, this message translates to:
  /// **'Average price'**
  String get avgPrice;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Fuel costs label
  ///
  /// In en, this message translates to:
  /// **'Fuel costs'**
  String get fuelCosts;

  /// Save error message
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String saveError(String error);

  /// Title field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g. Oil change'**
  String get titleHint;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description/Notes'**
  String get descriptionLabel;

  /// Description field hint text
  ///
  /// In en, this message translates to:
  /// **'Additional information about the expense...'**
  String get descriptionHint;

  /// Other expense type
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseTypeOther;

  /// Battery expense type
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get expenseTypeBattery;

  /// Repair expense type
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get expenseTypeRepair;

  /// Towing expense type
  ///
  /// In en, this message translates to:
  /// **'Towing'**
  String get expenseTypeTowing;

  /// Insurance expense type
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get expenseTypeInsurance;

  /// Inspection expense type
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get expenseTypeInspection;

  /// Unknown expense type
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get expenseTypeUnknown;

  /// Refuel statistics card title
  ///
  /// In en, this message translates to:
  /// **'Refuel Statistics'**
  String get refuelStatistics;

  /// Expense statistics card title
  ///
  /// In en, this message translates to:
  /// **'Expense Statistics'**
  String get expenseStatistics;

  /// Number of refuels label
  ///
  /// In en, this message translates to:
  /// **'Number of refuels'**
  String get numberOfRefuels;

  /// Total fuel amount label
  ///
  /// In en, this message translates to:
  /// **'Total fuel amount'**
  String get totalFuelAmount;

  /// Average price per liter label
  ///
  /// In en, this message translates to:
  /// **'Average price per liter'**
  String get averagePricePerLiter;

  /// Average cost label
  ///
  /// In en, this message translates to:
  /// **'Average cost'**
  String get averageCost;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

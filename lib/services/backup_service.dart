import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'google_drive_service.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/expense.dart';
import '../utils/constants.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();
  final GoogleDriveService _googleDriveService = GoogleDriveService();

  // Export data to JSON
  Future<Map<String, dynamic>> exportData() async {
    try {
      final cars = await _databaseService.getAllCars();
      final backupData = <String, dynamic>{
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'cars': [],
      };

      for (final car in cars) {
        final refuels = await _databaseService.getRefuels(car.carName);
        final expenses = await _databaseService.getExpenses(
          car.carStatisticsTable,
        );

        backupData['cars'].add({
          'car': car.toMap(),
          'refuels': refuels.map((r) => r.toMap()).toList(),
          'expenses': expenses.map((e) => e.toMap()).toList(),
        });
      }

      return backupData;
    } catch (e) {
      throw Exception('Error exporting data: $e');
    }
  }

  // Import danych z JSON
  Future<void> importData(Map<String, dynamic> backupData) async {
    try {
      if (backupData['version'] == null) {
        throw Exception('Invalid backup format');
      }

      final cars = backupData['cars'] as List<dynamic>;

      for (final carData in cars) {
        final carMap = carData['car'] as Map<String, dynamic>;
        final car = Car.fromMap(carMap);

        // Check if car already exists
        final existingCars = await _databaseService.getAllCars();
        final carExists = existingCars.any((c) => c.carName == car.carName);

        if (!carExists) {
          // Add car
          await _databaseService.insertCar(car);
        }

        // Add refuels
        final refuelsData = carData['refuels'] as List<dynamic>;
        for (final refuelMap in refuelsData) {
          final refuel = Refuel.fromMap(refuelMap as Map<String, dynamic>);
          await _databaseService.insertRefuel(car.carName, refuel);
        }

        // Dodaj wydatki
        final expensesData = carData['expenses'] as List<dynamic>;
        for (final expenseMap in expensesData) {
          final expense = Expense.fromMap(expenseMap as Map<String, dynamic>);
          await _databaseService.insertExpense(car.carStatisticsTable, expense);
        }
      }
    } catch (e) {
      throw Exception('Error importing data: $e');
    }
  }

  // Export to file (web)
  Future<String> exportToJson() async {
    final data = await exportData();
    final jsonString = jsonEncode(data);

    // Check if generated JSON can be parsed back
    try {
      jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Error generating JSON: $e');
    }

    return jsonString;
  }

  // Import z JSON string
  Future<void> importFromJson(String jsonString) async {
    try {
      // Check if string is valid JSON
      final data = jsonDecode(jsonString);

      // Check if it's a Map (JSON object)
      if (data is! Map<String, dynamic>) {
        throw Exception(
          'JSON must be an object, not an array or primitive value',
        );
      }

      await importData(data);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid JSON format: ${e.message}');
      } else {
        throw Exception('Error parsing JSON: $e');
      }
    }
  }

  // Export to file (prepare data for download)
  Future<Uint8List> exportToFile() async {
    final jsonString = await exportToJson();
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  // Check if backup is valid
  bool validateBackup(String jsonString) {
    try {
      final data = jsonDecode(jsonString);

      // Check if it's a JSON object
      if (data is! Map<String, dynamic>) {
        return false;
      }

      // Check required fields
      if (!data.containsKey('version') ||
          !data.containsKey('timestamp') ||
          !data.containsKey('cars')) {
        return false;
      }

      // Check if cars is a list
      if (data['cars'] is! List) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== SQLITE HANDLING =====

  // Export SQLite file (only on platforms with SQLite)
  Future<Uint8List?> exportSqliteDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite export is not supported on web');
    }

    try {
      // Get database path
      final databasePath = await _getDatabasePath();
      final file = File(databasePath);

      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        throw Exception('Database file does not exist');
      }
    } catch (e) {
      throw Exception('Error exporting SQLite database: $e');
    }
  }

  // Import SQLite file (only on platforms with SQLite)
  Future<void> importSqliteDatabase(Uint8List sqliteData) async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite import is not supported on web');
    }

    try {
      // Close existing database connection
      await _databaseService.close();

      // Get database path
      final databasePath = await _getDatabasePath();

      // Create backup of existing database
      final existingFile = File(databasePath);
      if (await existingFile.exists()) {
        final backupPath =
            '$databasePath.backup.${DateTime.now().millisecondsSinceEpoch}';
        await existingFile.copy(backupPath);
      }

      // Save new database
      await File(databasePath).writeAsBytes(sqliteData);

      // Reset database connection in DatabaseService
      await _databaseService.resetDatabase();
    } catch (e) {
      throw Exception('Error importing SQLite database: $e');
    }
  }

  // Check if file is SQLite
  bool validateSqliteFile(Uint8List data) {
    if (data.length < 16) return false;

    // SQLite files start with "SQLite format 3\0"
    final header = String.fromCharCodes(data.take(15));
    return header == 'SQLite format 3';
  }

  // Get database file path
  Future<String> _getDatabasePath() async {
    final String databaseName = kFuelcalcDatabaseName;
    return join(await getDatabasesPath(), databaseName);
  }

  // ===== GOOGLE DRIVE INTEGRATION =====

  // Get Google Drive service
  GoogleDriveService get googleDriveService => _googleDriveService;

  // Export SQLite database to Google Drive
  Future<String> exportSqliteToGoogleDrive({required String fileName}) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite export to Google Drive is not supported on web',
      );
    }

    try {
      // Get the SQLite database bytes
      final sqliteData = await exportSqliteDatabase();
      if (sqliteData == null) {
        throw Exception('Failed to export SQLite database');
      }

      // Sign in if not already signed in
      if (!_googleDriveService.isSignedIn()) {
        final signedIn = await _googleDriveService.signIn();
        if (!signedIn) {
          throw Exception('Failed to sign in to Google Drive');
        }
      }

      // Find or create FuelCalc folder
      final folderId = await _googleDriveService.findOrCreateFolder(
        'FuelCalc_Backups',
      );

      // Upload file to Google Drive (replace if exists)
      final fileId = await _googleDriveService.uploadFile(
        fileName: fileName,
        fileBytes: sqliteData,
        mimeType: 'application/x-sqlite3',
        folderId: folderId,
        replaceExisting: true,
      );

      if (fileId == null) {
        throw Exception('Failed to upload file to Google Drive');
      }

      return fileId;
    } catch (e) {
      throw Exception('Error exporting to Google Drive: $e');
    }
  }

  // Import SQLite database from Google Drive
  Future<void> importSqliteFromGoogleDrive(String fileId) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite import from Google Drive is not supported on web',
      );
    }

    try {
      // Sign in if not already signed in
      if (!_googleDriveService.isSignedIn()) {
        final signedIn = await _googleDriveService.signIn();
        if (!signedIn) {
          throw Exception('Failed to sign in to Google Drive');
        }
      }

      // Download file from Google Drive
      final sqliteData = await _googleDriveService.downloadFile(fileId);
      if (sqliteData == null) {
        throw Exception('Failed to download file from Google Drive');
      }

      // Import the database
      await importSqliteDatabase(sqliteData);
    } catch (e) {
      throw Exception('Error importing from Google Drive: $e');
    }
  }
}

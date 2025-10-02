import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/expense.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();

  // Eksport danych do JSON
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
        final expenses = await _databaseService.getExpenses(car.carStatisticsTable);
        
        backupData['cars'].add({
          'car': car.toMap(),
          'refuels': refuels.map((r) => r.toMap()).toList(),
          'expenses': expenses.map((e) => e.toMap()).toList(),
        });
      }

      return backupData;
    } catch (e) {
      throw Exception('Błąd podczas eksportu danych: $e');
    }
  }

  // Import danych z JSON
  Future<void> importData(Map<String, dynamic> backupData) async {
    try {
      if (backupData['version'] == null) {
        throw Exception('Nieprawidłowy format backupu');
      }

      final cars = backupData['cars'] as List<dynamic>;
      
      for (final carData in cars) {
        final carMap = carData['car'] as Map<String, dynamic>;
        final car = Car.fromMap(carMap);
        
        // Sprawdź czy samochód już istnieje
        final existingCars = await _databaseService.getAllCars();
        final carExists = existingCars.any((c) => c.carName == car.carName);
        
        if (!carExists) {
          // Dodaj samochód
          await _databaseService.insertCar(car);
        }
        
        // Dodaj tankowania
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
      throw Exception('Błąd podczas importu danych: $e');
    }
  }

  // Eksport do pliku (web)
  Future<String> exportToJson() async {
    final data = await exportData();
    return jsonEncode(data);
  }

  // Import z JSON string
  Future<void> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      await importData(data);
    } catch (e) {
      throw Exception('Błąd parsowania JSON: $e');
    }
  }

  // Eksport do pliku (przygotowanie danych do pobrania)
  Future<Uint8List> exportToFile() async {
    final jsonString = await exportToJson();
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  // Sprawdzenie czy backup jest prawidłowy
  bool validateBackup(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return data.containsKey('version') && 
             data.containsKey('timestamp') && 
             data.containsKey('cars');
    } catch (e) {
      return false;
    }
  }

  // ===== OBSŁUGA SQLITE =====

  // Eksport pliku SQLite (tylko na platformach z SQLite)
  Future<Uint8List?> exportSqliteDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite export nie jest obsługiwany na web');
    }

    try {
      // Pobierz ścieżkę do bazy danych
      final databasePath = await _getDatabasePath();
      final file = File(databasePath);
      
      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        throw Exception('Plik bazy danych nie istnieje');
      }
    } catch (e) {
      throw Exception('Błąd eksportu bazy SQLite: $e');
    }
  }

  // Import pliku SQLite (tylko na platformach z SQLite)
  Future<void> importSqliteDatabase(Uint8List sqliteData) async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite import nie jest obsługiwany na web');
    }

    try {
      // Zamknij istniejące połączenie z bazą
      await _databaseService.close();
      
      // Pobierz ścieżkę do bazy danych
      final databasePath = await _getDatabasePath();
      
      // Utwórz backup istniejącej bazy
      final existingFile = File(databasePath);
      if (await existingFile.exists()) {
        final backupPath = '$databasePath.backup.${DateTime.now().millisecondsSinceEpoch}';
        await existingFile.copy(backupPath);
      }
      
      // Zapisz nową bazę danych
      await File(databasePath).writeAsBytes(sqliteData);
      
      // Zresetuj połączenie z bazą w DatabaseService
      await _databaseService.resetDatabase();
      
    } catch (e) {
      throw Exception('Błąd importu bazy SQLite: $e');
    }
  }

  // Sprawdzenie czy plik to SQLite
  bool validateSqliteFile(Uint8List data) {
    if (data.length < 16) return false;
    
    // SQLite pliki zaczynają się od "SQLite format 3\0"
    final header = String.fromCharCodes(data.take(15));
    return header == 'SQLite format 3';
  }

  // Pobierz ścieżkę do pliku bazy danych
  Future<String> _getDatabasePath() async {
    final String databaseName = 'fuel_calculator.db';
    return join(await getDatabasesPath(), databaseName);
  }
}
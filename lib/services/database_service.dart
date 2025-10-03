import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/car.dart';
import '../models/refuel.dart';
import '../models/expense.dart';

class DatabaseService {
  static Database? _database;
  static SharedPreferences? _prefs;
  static const String _databaseName = 'fuelcalc.db';
  static const int _databaseVersion = 1;

  // Klucze dla SharedPreferences
  static const String _carsKey = 'cars';
  static const String _refuelsPrefix = 'refuels_';
  static const String _expensesPrefix = 'expenses_';

  Future<Database?> get database async {
    if (kIsWeb) {
      return null; // Na web używamy SharedPreferences
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web');
    }

    // Inicjalizacja FFI dla desktop platform
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela główna z pojazdami
    await db.execute('''
      CREATE TABLE car_host (
        _car_id INTEGER PRIMARY KEY AUTOINCREMENT,
        car_name TEXT NOT NULL,
        car_desctription TEXT,
        car_alias_name TEXT,
        car_algoritm TEXT,
        car_initial_millage INTEGER DEFAULT 0,
        car_traveled_distance INTEGER DEFAULT 0,
        car_relative_volume REAL DEFAULT 40,
        car_enable_relative_volume INTEGER DEFAULT 0,
        car_chart_preferences TEXT,
        car_statistics_table TEXT NOT NULL
      )
    ''');

    // Tabela sekwencji (dla kompatybilności z SQLite)
    await db.execute('''
      CREATE TABLE sqlite_sequence(name TEXT, seq INTEGER)
    ''');
  }

  // ===== OPERACJE NA POJAZDACH =====

  Future<int> insertCar(Car car) async {
    if (kIsWeb) {
      return await _insertCarWeb(car);
    } else {
      return await _insertCarSqlite(car);
    }
  }

  Future<int> _insertCarWeb(Car car) async {
    final prefs = await this.prefs;
    final cars = await getAllCars();
    
    // Generuj ID i nazwy tabel
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final carId = cars.length + 1;
    final carTableName = 'car_${carId}_$timestamp';
    final statsTableName = 'stats_${carId}_$timestamp';
    
    final carWithTables = car.copyWith(
      id: carId,
      carName: carTableName,
      carStatisticsTable: statsTableName,
    );
    
    cars.add(carWithTables);
    
    // Zapisz listę samochodów
    final carsJson = cars.map((c) => c.toMap()).toList();
    await prefs.setString(_carsKey, jsonEncode(carsJson));
    
    // Utwórz puste listy dla tankowań i wydatków
    await prefs.setString('$_refuelsPrefix$carTableName', jsonEncode([]));
    await prefs.setString('$_expensesPrefix$statsTableName', jsonEncode([]));
    
    return carId;
  }

  Future<int> _insertCarSqlite(Car car) async {
    final db = await database;
    if (db == null) return 0;
    
    // Generuj unikalne nazwy tabel dla nowego samochodu
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final carTableName = 'car_${car.id ?? timestamp}';
    final statsTableName = 'stats_${car.id ?? timestamp}';
    
    // Utwórz nowy samochód z odpowiednimi nazwami tabel
    final carWithTables = car.copyWith(
      carName: carTableName,
      carStatisticsTable: statsTableName,
    );
    
    // Wstaw samochód do tabeli car_host
    final carId = await db.insert('car_host', carWithTables.toMap());
    
    // Utwórz dedykowane tabele dla tankowań i wydatków
    await _createCarTables(db, carTableName, statsTableName);
    
    return carId;
  }

  Future<void> _createCarTables(Database db, String carTableName, String statsTableName) async {
    // Tabela tankowań dla samochodu
    await db.execute('''
      CREATE TABLE $carTableName (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        odometer_state REAL DEFAULT 0,
        volumes REAL DEFAULT 4.5,
        prize REAL DEFAULT 4,
        information TEXT,
        rating REAL DEFAULT 5,
        date TEXT NOT NULL,
        distance REAL DEFAULT 200,
        gps_latitude REAL DEFAULT 0,
        gps_longitude REAL DEFAULT 0,
        refuel_type INTEGER DEFAULT 0
      )
    ''');

    // Tabela wydatków dla samochodu
    await db.execute('''
      CREATE TABLE $statsTableName (
        _statistics_row_id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        information TEXT,
        statistic_title TEXT NOT NULL,
        statistic_cost REAL DEFAULT 0,
        statistic_type INTEGER DEFAULT 0,
        statistic_subtype INTEGER DEFAULT 0,
        statistic_rating REAL DEFAULT 5
      )
    ''');
  }

  Future<List<Car>> getAllCars() async {
    if (kIsWeb) {
      return await _getAllCarsWeb();
    } else {
      return await _getAllCarsSqlite();
    }
  }

  Future<List<Car>> _getAllCarsWeb() async {
    final prefs = await this.prefs;
    final carsJson = prefs.getString(_carsKey);
    if (carsJson == null) return [];
    
    final List<dynamic> carsList = jsonDecode(carsJson);
    return carsList.map((carMap) => Car.fromMap(carMap)).toList();
  }

  Future<List<Car>> _getAllCarsSqlite() async {
    final db = await database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query('car_host');
    return List.generate(maps.length, (i) => Car.fromMap(maps[i]));
  }

  Future<Car?> getCarById(int id) async {
    final cars = await getAllCars();
    try {
      return cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateCar(Car car) async {
    if (kIsWeb) {
      return await _updateCarWeb(car);
    } else {
      return await _updateCarSqlite(car);
    }
  }

  Future<int> _updateCarWeb(Car car) async {
    final prefs = await this.prefs;
    final cars = await getAllCars();
    
    final index = cars.indexWhere((c) => c.id == car.id);
    if (index == -1) return 0;
    
    cars[index] = car;
    
    final carsJson = cars.map((c) => c.toMap()).toList();
    await prefs.setString(_carsKey, jsonEncode(carsJson));
    
    return 1;
  }

  Future<int> _updateCarSqlite(Car car) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.update(
      'car_host',
      car.toMap(),
      where: '_car_id = ?',
      whereArgs: [car.id],
    );
  }

  Future<int> deleteCar(int id) async {
    if (kIsWeb) {
      return await _deleteCarWeb(id);
    } else {
      return await _deleteCarSqlite(id);
    }
  }

  Future<int> _deleteCarWeb(int id) async {
    final prefs = await this.prefs;
    final car = await getCarById(id);
    if (car == null) return 0;
    
    // Usuń dane pojazdu
    final cars = await getAllCars();
    cars.removeWhere((c) => c.id == id);
    
    final carsJson = cars.map((c) => c.toMap()).toList();
    await prefs.setString(_carsKey, jsonEncode(carsJson));
    
    // Usuń dane tankowań i wydatków
    await prefs.remove('$_refuelsPrefix${car.carName}');
    await prefs.remove('$_expensesPrefix${car.carStatisticsTable}');
    
    return 1;
  }

  Future<int> _deleteCarSqlite(int id) async {
    final db = await database;
    if (db == null) return 0;
    
    // Pobierz informacje o samochodzie
    final car = await getCarById(id);
    if (car == null) return 0;
    
    // Usuń dedykowane tabele
    await db.execute('DROP TABLE IF EXISTS ${car.carName}');
    await db.execute('DROP TABLE IF EXISTS ${car.carStatisticsTable}');
    
    // Usuń samochód z tabeli głównej
    return await db.delete(
      'car_host',
      where: '_car_id = ?',
      whereArgs: [id],
    );
  }

  // ===== OPERACJE NA TANKOWANIACH =====

  Future<int> insertRefuel(String tableName, Refuel refuel) async {
    if (kIsWeb) {
      return await _insertRefuelWeb(tableName, refuel);
    } else {
      return await _insertRefuelSqlite(tableName, refuel);
    }
  }

  Future<int> _insertRefuelWeb(String tableName, Refuel refuel) async {
    final prefs = await this.prefs;
    final refuels = await getRefuels(tableName);
    
    final newRefuel = refuel.copyWith(id: refuels.length + 1);
    refuels.insert(0, newRefuel); // Dodaj na początek (najnowsze pierwsze)
    
    final refuelsJson = refuels.map((r) => r.toMap()).toList();
    await prefs.setString('$_refuelsPrefix$tableName', jsonEncode(refuelsJson));
    
    return newRefuel.id!;
  }

  Future<int> _insertRefuelSqlite(String tableName, Refuel refuel) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.insert(tableName, refuel.toMap());
  }

  Future<List<Refuel>> getRefuels(String tableName, {int? limit}) async {
    if (kIsWeb) {
      return await _getRefuelsWeb(tableName, limit: limit);
    } else {
      return await _getRefuelsSqlite(tableName, limit: limit);
    }
  }

  Future<List<Refuel>> _getRefuelsWeb(String tableName, {int? limit}) async {
    final prefs = await this.prefs;
    final refuelsJson = prefs.getString('$_refuelsPrefix$tableName');
    if (refuelsJson == null) return [];
    
    final List<dynamic> refuelsList = jsonDecode(refuelsJson);
    var refuels = refuelsList.map((refuelMap) => Refuel.fromMap(refuelMap)).toList();
    
    // Sortuj po dacie (najnowsze pierwsze)
    refuels.sort((a, b) => b.date.compareTo(a.date));
    
    if (limit != null && limit > 0) {
      refuels = refuels.take(limit).toList();
    }
    
    return refuels;
  }

  Future<List<Refuel>> _getRefuelsSqlite(String tableName, {int? limit}) async {
    final db = await database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Refuel.fromMap(maps[i]));
  }

  Future<int> updateRefuel(String tableName, Refuel refuel) async {
    if (kIsWeb) {
      return await _updateRefuelWeb(tableName, refuel);
    } else {
      return await _updateRefuelSqlite(tableName, refuel);
    }
  }

  Future<int> _updateRefuelWeb(String tableName, Refuel refuel) async {
    final prefs = await this.prefs;
    final refuels = await getRefuels(tableName);
    
    final index = refuels.indexWhere((r) => r.id == refuel.id);
    if (index == -1) return 0;
    
    refuels[index] = refuel;
    
    final refuelsJson = refuels.map((r) => r.toMap()).toList();
    await prefs.setString('$_refuelsPrefix$tableName', jsonEncode(refuelsJson));
    
    return 1;
  }

  Future<int> _updateRefuelSqlite(String tableName, Refuel refuel) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.update(
      tableName,
      refuel.toMap(),
      where: '_id = ?',
      whereArgs: [refuel.id],
    );
  }

  Future<int> deleteRefuel(String tableName, int id) async {
    if (kIsWeb) {
      return await _deleteRefuelWeb(tableName, id);
    } else {
      return await _deleteRefuelSqlite(tableName, id);
    }
  }

  Future<int> _deleteRefuelWeb(String tableName, int id) async {
    final prefs = await this.prefs;
    final refuels = await getRefuels(tableName);
    
    refuels.removeWhere((r) => r.id == id);
    
    final refuelsJson = refuels.map((r) => r.toMap()).toList();
    await prefs.setString('$_refuelsPrefix$tableName', jsonEncode(refuelsJson));
    
    return 1;
  }

  Future<int> _deleteRefuelSqlite(String tableName, int id) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.delete(
      tableName,
      where: '_id = ?',
      whereArgs: [id],
    );
  }

  // ===== OPERACJE NA WYDATKACH =====

  Future<int> insertExpense(String tableName, Expense expense) async {
    if (kIsWeb) {
      return await _insertExpenseWeb(tableName, expense);
    } else {
      return await _insertExpenseSqlite(tableName, expense);
    }
  }

  Future<int> _insertExpenseWeb(String tableName, Expense expense) async {
    final prefs = await this.prefs;
    final expenses = await getExpenses(tableName);
    
    final newExpense = expense.copyWith(id: expenses.length + 1);
    expenses.insert(0, newExpense); // Dodaj na początek (najnowsze pierwsze)
    
    final expensesJson = expenses.map((e) => e.toMap()).toList();
    await prefs.setString('$_expensesPrefix$tableName', jsonEncode(expensesJson));
    
    return newExpense.id!;
  }

  Future<int> _insertExpenseSqlite(String tableName, Expense expense) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.insert(tableName, expense.toMap());
  }

  Future<List<Expense>> getExpenses(String tableName, {int? limit}) async {
    if (kIsWeb) {
      return await _getExpensesWeb(tableName, limit: limit);
    } else {
      return await _getExpensesSqlite(tableName, limit: limit);
    }
  }

  Future<List<Expense>> _getExpensesWeb(String tableName, {int? limit}) async {
    final prefs = await this.prefs;
    final expensesJson = prefs.getString('$_expensesPrefix$tableName');
    if (expensesJson == null) return [];
    
    final List<dynamic> expensesList = jsonDecode(expensesJson);
    var expenses = expensesList.map((expenseMap) => Expense.fromMap(expenseMap)).toList();
    
    // Sortuj po dacie (najnowsze pierwsze)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    
    if (limit != null && limit > 0) {
      expenses = expenses.take(limit).toList();
    }
    
    return expenses;
  }

  Future<List<Expense>> _getExpensesSqlite(String tableName, {int? limit}) async {
    final db = await database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> updateExpense(String tableName, Expense expense) async {
    if (kIsWeb) {
      return await _updateExpenseWeb(tableName, expense);
    } else {
      return await _updateExpenseSqlite(tableName, expense);
    }
  }

  Future<int> _updateExpenseWeb(String tableName, Expense expense) async {
    final prefs = await this.prefs;
    final expenses = await getExpenses(tableName);
    
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) return 0;
    
    expenses[index] = expense;
    
    final expensesJson = expenses.map((e) => e.toMap()).toList();
    await prefs.setString('$_expensesPrefix$tableName', jsonEncode(expensesJson));
    
    return 1;
  }

  Future<int> _updateExpenseSqlite(String tableName, Expense expense) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.update(
      tableName,
      expense.toMap(),
      where: '_statistics_row_id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String tableName, int id) async {
    if (kIsWeb) {
      return await _deleteExpenseWeb(tableName, id);
    } else {
      return await _deleteExpenseSqlite(tableName, id);
    }
  }

  Future<int> _deleteExpenseWeb(String tableName, int id) async {
    final prefs = await this.prefs;
    final expenses = await getExpenses(tableName);
    
    expenses.removeWhere((e) => e.id == id);
    
    final expensesJson = expenses.map((e) => e.toMap()).toList();
    await prefs.setString('$_expensesPrefix$tableName', jsonEncode(expensesJson));
    
    return 1;
  }

  Future<int> _deleteExpenseSqlite(String tableName, int id) async {
    final db = await database;
    if (db == null) return 0;
    
    return await db.delete(
      tableName,
      where: '_statistics_row_id = ?',
      whereArgs: [id],
    );
  }

  // ===== STATYSTYKI =====

  Future<Map<String, dynamic>> getRefuelStatistics(String tableName, int count) async {
    final refuels = await getRefuels(tableName, limit: count);
    
    if (refuels.isEmpty) {
      return {
        'count': 0,
        'totalVolume': 0.0,
        'totalCost': 0.0,
        'totalDistance': 0.0,
        'avgConsumption': 0.0,
        'avgPricePerLiter': 0.0,
      };
    }
    
    final totalVolume = refuels.fold(0.0, (sum, refuel) => sum + refuel.volumes);
    final totalCost = refuels.fold(0.0, (sum, refuel) => sum + refuel.prize);
    final totalDistance = refuels.fold(0.0, (sum, refuel) => sum + refuel.distance);
    
    final avgConsumption = totalDistance > 0 ? (totalVolume / totalDistance) * 100 : 0.0;
    final avgPricePerLiter = totalVolume > 0 ? totalCost / totalVolume : 0.0;
    
    return {
      'count': refuels.length,
      'totalVolume': totalVolume,
      'totalCost': totalCost,
      'totalDistance': totalDistance,
      'avgConsumption': avgConsumption,
      'avgPricePerLiter': avgPricePerLiter,
    };
  }

  Future<Map<String, dynamic>> getExpenseStatistics(String tableName, int count) async {
    final expenses = await getExpenses(tableName, limit: count);
    
    if (expenses.isEmpty) {
      return {
        'count': 0,
        'totalCost': 0.0,
        'avgCost': 0.0,
        'categoryCosts': <int, double>{},
      };
    }
    
    final totalCost = expenses.fold(0.0, (sum, expense) => sum + expense.statisticCost);
    final avgCost = totalCost / expenses.length;
    
    // Grupuj koszty według kategorii
    final Map<int, double> categoryCosts = {};
    for (final expense in expenses) {
      categoryCosts[expense.statisticType] = 
          (categoryCosts[expense.statisticType] ?? 0.0) + expense.statisticCost;
    }
    
    return {
      'count': expenses.length,
      'totalCost': totalCost,
      'avgCost': avgCost,
      'categoryCosts': categoryCosts,
    };
  }

  Future<List<Map<String, dynamic>>> getRefuelChartData(String tableName, int count) async {
    final refuels = await getRefuels(tableName, limit: count);
    
    return refuels.reversed.map((refuel) => {
      'date': refuel.date.toIso8601String(),
      'volume': refuel.volumes,
      'consumption': refuel.consumption,
      'cost': refuel.prize,
    }).toList();
  }

  // Zamknij bazę danych
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Zresetuj połączenie z bazą danych (dla importu SQLite)
  Future<void> resetDatabase() async {
    await close();
    if (!kIsWeb) {
      _database = await _initDatabase();
    }
  }
}
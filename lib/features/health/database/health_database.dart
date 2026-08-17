import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_health_tracker/features/health/models/health_measurement.dart';
import 'package:smart_health_tracker/features/profile/models/user_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:smart_health_tracker/features/reminder/models/health_reminder.dart';
import 'package:smart_health_tracker/features/health/analysis/health_threshold.dart';
class HealthDatabase {
  static final HealthDatabase instance = HealthDatabase._internal();

  HealthDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;

      return databaseFactory.openDatabase(
        'smart_health_tracker.db',
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        ),
      );
    }

    // Windows / Linux / macOS
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();

      databaseFactory = databaseFactoryFfi;

      final databasePath = await databaseFactory.getDatabasesPath();

      final path = join(
        databasePath,
        'smart_health_tracker.db',
      );

      return databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        ),
      );
    }

    // Android / iOS
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'smart_health_tracker.db',
    );

    return openDatabase(
      path,
      version: 4,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE health_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic REAL NOT NULL,
        diastolic REAL NOT NULL,
        heart_rate REAL NOT NULL,
        blood_glucose REAL NOT NULL,
        measured_at TEXT NOT NULL,
        note TEXT
      )
    ''');
    await db.execute('''
    CREATE TABLE user_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      gender TEXT NOT NULL,
      height REAL NOT NULL,
      weight REAL NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE health_reminders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      type TEXT NOT NULL,
      hour INTEGER NOT NULL,
      minute INTEGER NOT NULL,
      enabled INTEGER NOT NULL
    )
  ''');
    await db.execute('''
  CREATE TABLE health_thresholds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    heart_rate_min REAL NOT NULL,
    heart_rate_max REAL NOT NULL,

    systolic_min REAL NOT NULL,
    systolic_max REAL NOT NULL,

    diastolic_min REAL NOT NULL,
    diastolic_max REAL NOT NULL,

    glucose_min REAL NOT NULL,
    glucose_max REAL NOT NULL
  )
''');
  }
  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL
      )
    ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE health_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        enabled INTEGER NOT NULL
      )
    ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE health_thresholds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        heart_rate_min REAL NOT NULL,
        heart_rate_max REAL NOT NULL,

        systolic_min REAL NOT NULL,
        systolic_max REAL NOT NULL,

        diastolic_min REAL NOT NULL,
        diastolic_max REAL NOT NULL,

        glucose_min REAL NOT NULL,
        glucose_max REAL NOT NULL
      )
    ''');
    }
  }
  Future<int> insertMeasurement(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.insert(
      'health_measurements',
      data,
    );
  }
  Future<List<HealthMeasurement>> getMeasurements() async {
    final db = await database;

    final maps = await db.query(
      'health_measurements',
      orderBy: 'measured_at DESC',
    );

    return maps
        .map(
          (map) => HealthMeasurement.fromMap(map),
    )
        .toList();
  }
  Future<HealthMeasurement?> getLatestMeasurement() async {
    final db = await database;

    final maps = await db.query(
      'health_measurements',
      orderBy: 'measured_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return HealthMeasurement.fromMap(
      maps.first,
    );
  }
  Future<UserProfile?> getUserProfile() async {
    final db = await database;

    final maps = await db.query(
      'user_profile',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserProfile.fromMap(
      maps.first,
    );
  }
  Future<int> insertUserProfile(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.insert(
      'user_profile',
      data,
    );
  }
  Future<int> updateUserProfile(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'user_profile',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> updateMeasurement(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'health_measurements',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteMeasurement(int id) async {
    final db = await database;

    return await db.delete(
      'health_measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> insertReminder(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.insert(
      'health_reminders',
      data,
    );
  }
  Future<List<HealthReminder>> getReminders() async {
    final db = await database;

    final maps = await db.query(
      'health_reminders',
      orderBy: 'hour ASC, minute ASC',
    );

    return maps
        .map(
          (map) => HealthReminder.fromMap(map),
    )
        .toList();
  }
  Future<int> updateReminder(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'health_reminders',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> deleteReminder(
      int id,
      ) async {
    final db = await database;

    return await db.delete(
      'health_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<HealthThreshold?> getHealthThreshold() async {
    final db = await database;

    final maps = await db.query(
      'health_thresholds',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return HealthThreshold.fromMap(
      maps.first,
    );
  }
  Future<int> insertHealthThreshold(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.insert(
      'health_thresholds',
      data,
    );
  }
  Future<int> updateHealthThreshold(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'health_thresholds',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> saveHealthThreshold(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    final existing = await db.query(
      'health_thresholds',
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(
        'health_thresholds',
        data,
      );
    } else {
      await db.update(
        'health_thresholds',
        data,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }
}

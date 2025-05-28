import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import '../models/weather.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initializeDatabase() async {
    // Initialize FFI for sqflite
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize database
    await initializeDatabase();
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the application documents directory
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'weather_database.db');

    // Ensure the directory exists
    await Directory(dirname(path)).create(recursive: true);

    // Open the database
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {          // Create weather table
          await db.execute('''
            CREATE TABLE weather(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              city TEXT,
              temperature REAL,
              description TEXT,
              humidity INTEGER,
              windSpeed REAL,
              timestamp TEXT
            )
          ''');
            // Create settings table
          await db.execute('''
            CREATE TABLE settings(
              id INTEGER PRIMARY KEY CHECK (id = 1),
              temperatureUnit TEXT NOT NULL DEFAULT '°C',
              windSpeedUnit TEXT NOT NULL DEFAULT 'm/s',
              updateFrequency INTEGER NOT NULL DEFAULT 3600000
            )
          ''');
          
          // Insert default settings
          await db.insert('settings', {
            'id': 1,
            'temperatureUnit': '°C',
            'windSpeedUnit': 'm/s',
            'updateFrequency': 3600000  // 1 hour in milliseconds
          });
        },
      ),
    );
  }

  Future<int> insertWeather(Weather weather) async {
    Database db = await database;
    return await db.insert('weather', weather.toMap());
  }

  Future<List<Weather>> getWeathers() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('weather');
    return List.generate(maps.length, (i) => Weather.fromMap(maps[i]));
  }

  Future<int> updateWeather(Weather weather) async {
    Database db = await database;
    return await db.update(
      'weather',
      weather.toMap(),
      where: 'id = ?',
      whereArgs: [weather.id],
    );
  }

  Future<int> deleteWeather(int id) async {
    Database db = await database;
    return await db.delete(
      'weather',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getTemperatureUnit() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'settings',
      columns: ['temperatureUnit'],
      where: 'id = 1'
    );
    return result.first['temperatureUnit'] as String;
  }

  Future<void> updateTemperatureUnit(String unit) async {
    Database db = await database;
    await db.update(
      'settings',
      {'temperatureUnit': unit},
      where: 'id = 1'
    );
  }

  Future<String> getWindSpeedUnit() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'settings',
      columns: ['windSpeedUnit'],
      where: 'id = 1'
    );
    return result.first['windSpeedUnit'] as String;
  }

  Future<void> updateWindSpeedUnit(String unit) async {
    Database db = await database;
    await db.update(
      'settings',
      {'windSpeedUnit': unit},
      where: 'id = 1'
    );
  }

  Future<int> getUpdateFrequency() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'settings',
      columns: ['updateFrequency'],
      where: 'id = 1'
    );
    return result.first['updateFrequency'] as int;
  }

  Future<void> updateUpdateFrequency(int milliseconds) async {
    Database db = await database;
    await db.update(
      'settings',
      {'updateFrequency': milliseconds},
      where: 'id = 1'
    );
  }
}

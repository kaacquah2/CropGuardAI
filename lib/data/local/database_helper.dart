import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../domain/models/detection_result.dart';
import '../../domain/models/field.dart';

/// Equivalent of Room database + DAOs
class DatabaseHelper {
  static const _dbName = 'cropguard.db';
  static const _dbVersion = 10; // matches Room v10

  static const tableDetections = 'detections';
  static const tableFields = 'fields';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableDetections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL DEFAULT '',
        imagePath TEXT NOT NULL,
        diseaseLabel TEXT NOT NULL,
        displayName TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT NOT NULL DEFAULT 'unclear',
        isHealthy INTEGER NOT NULL,
        cropType TEXT NOT NULL,
        cause TEXT NOT NULL DEFAULT '',
        treatments TEXT NOT NULL DEFAULT '',
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableFields (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cropType TEXT NOT NULL,
        sizeHectares REAL NOT NULL DEFAULT 0,
        plantingDate INTEGER,
        userId TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Simple destructive upgrade for now (mirrors Room's fallbackToDestructiveMigration)
    await db.execute('DROP TABLE IF EXISTS $tableDetections');
    await db.execute('DROP TABLE IF EXISTS $tableFields');
    await _onCreate(db, newVersion);
  }

  // ─── Detections ──────────────────────────────────────────────────────────

  Future<int> insertDetection(DetectionResult result) async {
    final db = await database;
    return db.insert(tableDetections, result.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DetectionResult>> getAllDetections({String? userId}) async {
    final db = await database;
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final maps = await db.query(
      tableDetections,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    return maps.map(DetectionResult.fromMap).toList();
  }

  Future<DetectionResult?> getDetectionById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableDetections,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DetectionResult.fromMap(maps.first);
  }

  Future<List<DetectionResult>> getRecentDetections({int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      tableDetections,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map(DetectionResult.fromMap).toList();
  }

  Future<void> deleteAllDetections() async {
    final db = await database;
    await db.delete(tableDetections);
  }

  Future<void> deleteDetection(int id) async {
    final db = await database;
    await db.delete(tableDetections, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<Map<String, int>> getFarmStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableDetections'),
        ) ??
        0;
    final healthy = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM $tableDetections WHERE isHealthy = 1'),
        ) ??
        0;
    return {
      'total': total,
      'healthy': healthy,
      'diseased': total - healthy,
    };
  }

  Future<List<Map<String, dynamic>>> getDailyTrend({int days = 7}) async {
    final db = await database;
    final cutoff = DateTime.now()
            .subtract(Duration(days: days))
            .millisecondsSinceEpoch;
    return db.rawQuery('''
      SELECT
        date(timestamp / 1000, 'unixepoch') as day,
        SUM(CASE WHEN isHealthy = 1 THEN 1 ELSE 0 END) as healthyCount,
        SUM(CASE WHEN isHealthy = 0 THEN 1 ELSE 0 END) as diseasedCount
      FROM $tableDetections
      WHERE timestamp >= ?
      GROUP BY day
      ORDER BY day ASC
    ''', [cutoff]);
  }

  // ─── Fields ───────────────────────────────────────────────────────────────

  Future<void> upsertField(Field field) async {
    final db = await database;
    await db.insert(tableFields, field.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Field>> getFields({String? userId}) async {
    final db = await database;
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final maps = await db.query(tableFields,
        where: where, whereArgs: whereArgs, orderBy: 'name ASC');
    return maps.map(Field.fromMap).toList();
  }

  Future<void> deleteField(String id) async {
    final db = await database;
    await db.delete(tableFields, where: 'id = ?', whereArgs: [id]);
  }
}

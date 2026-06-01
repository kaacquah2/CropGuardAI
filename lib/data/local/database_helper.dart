import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/detection_result.dart';
import '../../domain/models/field.dart';
import '../../domain/models/treatment_plan.dart';

class DatabaseHelper {
  static const _dbName = 'cropguard.db';
  static const _dbVersion = 11;

  static const tableDetections = 'detections';
  static const tableFields = 'fields';
  static const tableTreatmentPlans = 'treatment_plans';
  static const tableNotifications = 'notifications';

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

    await _createTreatmentPlansTable(db);
    await _createNotificationsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 11) {
      await _createTreatmentPlansTable(db);
      await _createNotificationsTable(db);
    }
  }

  Future<void> _createTreatmentPlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTreatmentPlans (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL DEFAULT '',
        detectionId INTEGER NOT NULL DEFAULT 0,
        cropType TEXT NOT NULL,
        diseaseName TEXT NOT NULL,
        step TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        dueDateMs INTEGER NOT NULL,
        createdAtMs INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableNotifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'reminder',
        isRead INTEGER NOT NULL DEFAULT 0,
        createdAtMs INTEGER NOT NULL
      )
    ''');
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ─── Detections ──────────────────────────────────────────────────────────

  Future<int> insertDetection(DetectionResult result) async {
    final db = await database;
    return db.insert(
      tableDetections,
      result.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<List<DetectionResult>> getRecentDetections({
    String? userId,
    int limit = 5,
  }) async {
    final db = await database;
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final maps = await db.query(
      tableDetections,
      where: where,
      whereArgs: whereArgs,
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
            'SELECT COUNT(*) FROM $tableDetections WHERE isHealthy = 1',
          ),
        ) ??
        0;
    return {
      'total': total,
      'healthy': healthy,
      'diseased': total - healthy,
    };
  }

  Future<int> getDistinctDiseaseCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(DISTINCT diseaseLabel) FROM $tableDetections WHERE isHealthy = 0',
          ),
        ) ??
        0;
  }

  Future<int> getActiveDayStreak() async {
    final db = await database;
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT date(timestamp / 1000, 'unixepoch')) as days
      FROM $tableDetections
      WHERE timestamp >= ?
    ''', [cutoff]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getDailyTrend({int days = 7}) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
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
    await db.insert(
      tableFields,
      field.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Field>> getFields({String? userId}) async {
    final db = await database;
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final maps = await db.query(
      tableFields,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
    return maps.map(Field.fromMap).toList();
  }

  Future<void> deleteField(String id) async {
    final db = await database;
    await db.delete(tableFields, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Treatment Plans ─────────────────────────────────────────────────────

  Future<String> insertTreatment(TreatmentPlan plan) async {
    final db = await database;
    final payload = plan.id.isEmpty ? plan.copyWith(completed: plan.completed) : plan;
    final id = payload.id.isEmpty ? _newId() : payload.id;
    await db.insert(
      tableTreatmentPlans,
      {
        ...payload.toMap(),
        'id': id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<TreatmentPlan>> getAllTreatments({String? userId}) async {
    final db = await database;
    final where = userId != null ? 'userId = ?' : null;
    final whereArgs = userId != null ? [userId] : null;
    final maps = await db.query(
      tableTreatmentPlans,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'dueDateMs ASC',
    );
    return maps.map(TreatmentPlan.fromMap).toList();
  }

  Future<void> updateTreatmentCompleted(String id, bool completed) async {
    final db = await database;
    await db.update(
      tableTreatmentPlans,
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTreatment(String id) async {
    final db = await database;
    await db.delete(tableTreatmentPlans, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCompletedTreatmentsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableTreatmentPlans WHERE completed = 1',
          ),
        ) ??
        0;
  }

  // Backward-compatible wrappers.
  Future<int> insertTreatmentPlan(Map<String, dynamic> plan) async {
    final treatment = TreatmentPlan.fromMap(plan);
    return int.tryParse(await insertTreatment(treatment)) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTreatmentPlans({String? userId}) async {
    final items = await getAllTreatments(userId: userId);
    return items.map((item) => item.toMap()).toList();
  }

  Future<void> updateTreatmentPlanCompleted(int id, bool completed) async {
    await updateTreatmentCompleted(id.toString(), completed);
  }

  Future<void> deleteTreatmentPlan(int id) async {
    await deleteTreatment(id.toString());
  }

  Future<int> getCompletedTreatmentPlanCount() async {
    return getCompletedTreatmentsCount();
  }

  // ─── Notifications ───────────────────────────────────────────────────────

  Future<String> insertNotification(AppNotification notification) async {
    final db = await database;
    final id = notification.id.isEmpty ? _newId() : notification.id;
    await db.insert(
      tableNotifications,
      {
        ...notification.toMap(),
        'id': id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<AppNotification>> getNotifications() async {
    final db = await database;
    final maps = await db.query(
      tableNotifications,
      orderBy: 'createdAtMs DESC',
    );
    return maps.map(AppNotification.fromMap).toList();
  }

  Future<int> getUnreadNotificationsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $tableNotifications WHERE isRead = 0',
          ),
        ) ??
        0;
  }

  Future<void> markNotificationsAsRead() async {
    final db = await database;
    await db.update(tableNotifications, {'isRead': 1});
  }

  Future<void> markNotificationRead(String id) async {
    final db = await database;
    await db.update(
      tableNotifications,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete(tableNotifications, where: 'id = ?', whereArgs: [id]);
  }

  // Backward-compatible wrappers.
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final items = await getNotifications();
    return items.map((item) => item.toMap()).toList();
  }

  Future<int> getUnreadNotificationCount() async {
    return getUnreadNotificationsCount();
  }

  Future<void> markAllNotificationsRead() async {
    await markNotificationsAsRead();
  }
}

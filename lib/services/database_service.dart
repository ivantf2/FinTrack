import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/exercise.dart';
import '../models/workout_set.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'fittrack.db');

    return databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) => _createTables(db),
        onUpgrade: (db, oldVersion, newVersion) => _createTables(db),
      ),
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercises (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        description TEXT NOT NULL,
        gif_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workouts (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        exercise_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        goal TEXT NOT NULL,
        unit TEXT NOT NULL
      )
    ''');
  }

  static Future<void> seedExercises(List<Exercise> exercises) async {
    final db = await database;
    final batch = db.batch();

    for (final exercise in exercises) {
      batch.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  static Future<List<Exercise>> getExercises() async {
    final db = await database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(Exercise.fromMap).toList();
  }

  static Future<void> upsertExercises(List<Exercise> exercises) async {
    final db = await database;
    final batch = db.batch();

    for (final exercise in exercises) {
      batch.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  static Future<void> insertWorkout({
    required int id,
    required String name,
    required List<int> exerciseIds,
    DateTime? date,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert(
        'workouts',
        {
          'id': id,
          'name': name,
          'date': date?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'workout_exercises',
        where: 'workout_id = ?',
        whereArgs: [id],
      );

      for (var i = 0; i < exerciseIds.length; i++) {
        await txn.insert('workout_exercises', {
          'workout_id': id,
          'exercise_id': exerciseIds[i],
          'exercise_order': i,
        });
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    return db.query('workouts', orderBy: 'date DESC');
  }

  static Future<List<int>> getWorkoutExerciseIds(int workoutId) async {
    final db = await database;
    final rows = await db.query(
      'workout_exercises',
      columns: ['exercise_id'],
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'exercise_order ASC',
    );

    return rows.map((row) => row['exercise_id'] as int).toList();
  }

  static Future<void> saveWorkoutSets({
    required int workoutId,
    required int exerciseId,
    required List<WorkoutSet> sets,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(
        'sets',
        where: 'workout_id = ? AND exercise_id = ?',
        whereArgs: [workoutId, exerciseId],
      );

      for (final set in sets) {
        if (set.weight <= 0 || set.reps <= 0) continue;

        await txn.insert('sets', {
          'workout_id': workoutId,
          'exercise_id': exerciseId,
          'set_number': set.setNumber,
          'weight': set.weight,
          'reps': set.reps,
          'completed': set.completed ? 1 : 0,
        });
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getWorkoutSets(
    int workoutId,
  ) async {
    final db = await database;
    return db.query(
      'sets',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'exercise_id ASC, set_number ASC',
    );
  }

  static Future<void> deleteWorkout(int id) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('sets', where: 'workout_id = ?', whereArgs: [id]);
      await txn.delete(
        'workout_exercises',
        where: 'workout_id = ?',
        whereArgs: [id],
      );
      await txn.delete('workouts', where: 'id = ?', whereArgs: [id]);
    });
  }

  static Future<int> getWorkoutCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM workouts',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<int> getSetCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM sets',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<double> getTotalVolume() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(weight * reps), 0) AS volume FROM sets',
    );
    return ((result.first['volume'] as num?) ?? 0).toDouble();
  }

  static Future<List<Map<String, dynamic>>> getDailyStats({
    int days = 7,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];

    for (var i = days - 1; i >= 0; i--) {
      final start = today.subtract(Duration(days: i));
      final end = start.add(const Duration(days: 1));

      final volumeRows = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(s.weight * s.reps), 0) AS volume
        FROM sets s
        INNER JOIN workouts w ON w.id = s.workout_id
        WHERE w.date >= ? AND w.date < ?
        ''',
        [start.toIso8601String(), end.toIso8601String()],
      );

      final workoutRows = await db.rawQuery(
        '''
        SELECT COUNT(*) AS count FROM workouts
        WHERE date >= ? AND date < ?
        ''',
        [start.toIso8601String(), end.toIso8601String()],
      );

      final setRows = await db.rawQuery(
        '''
        SELECT COUNT(*) AS count
        FROM sets s
        INNER JOIN workouts w ON w.id = s.workout_id
        WHERE w.date >= ? AND w.date < ?
        ''',
        [start.toIso8601String(), end.toIso8601String()],
      );

      result.add({
        'date': start.toIso8601String(),
        'volume': ((volumeRows.first['volume'] as num?) ?? 0).toDouble(),
        'workouts': (workoutRows.first['count'] as int?) ?? 0,
        'sets': (setRows.first['count'] as int?) ?? 0,
      });
    }

    return result;
  }

  static Future<Map<String, dynamic>?> getPersonalRecord() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT s.exercise_id, s.weight, s.reps, e.name
      FROM sets s
      INNER JOIN exercises e ON e.id = s.exercise_id
      WHERE s.weight > 0 AND s.reps > 0
      ORDER BY s.weight DESC, s.reps DESC
      LIMIT 1
    ''');

    return rows.isEmpty ? null : rows.first;
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final rows = await db.query(
      'profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<void> saveProfile({
    required String name,
    required double height,
    required double weight,
    required String goal,
    required String unit,
  }) async {
    final db = await database;
    await db.insert(
      'profile',
      {
        'id': 1,
        'name': name,
        'height': height,
        'weight': weight,
        'goal': goal,
        'unit': unit,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

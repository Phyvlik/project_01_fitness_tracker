import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../models/quest.dart';

/// Singleton that manages all SQLite database operations.
/// Handles initialization, schema creation, and CRUD for all tables.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates all tables and seeds the exercise library on first launch
  Future<void> _createDB(Database db, int version) async {
    // Exercise library table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        equipment TEXT NOT NULL,
        description TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Workout sessions table
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        intensity TEXT NOT NULL,
        quest_id INTEGER
      )
    ''');

    // Exercises within a workout session
    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL DEFAULT 0.0,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // Quests / challenges table
    await db.execute('''
      CREATE TABLE quests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        target_workouts INTEGER NOT NULL,
        completed_workouts INTEGER NOT NULL DEFAULT 0,
        reward TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_date TEXT NOT NULL
      )
    ''');

    // Seed predefined exercises
    await _seedExercises(db);

    // Seed starter quests
    await _seedQuests(db);
  }

  // ---------------------------------------------------------------------------
  // EXERCISE CRUD
  // ---------------------------------------------------------------------------

  /// Insert a new exercise and return its new id
  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all exercises, optionally filtered by category or difficulty
  Future<List<Exercise>> getExercises({
    String? category,
    String? difficulty,
    String? equipment,
    String? searchQuery,
  }) async {
    final db = await database;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      conditions.add('difficulty = ?');
      args.add(difficulty);
    }
    if (equipment != null && equipment.isNotEmpty) {
      conditions.add('equipment = ?');
      args.add(equipment);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('(name LIKE ? OR description LIKE ?)');
      args.add('%$searchQuery%');
      args.add('%$searchQuery%');
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final maps = await db.query(
      'exercises',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'name ASC',
    );

    return maps.map((m) => Exercise.fromMap(m)).toList();
  }

  /// Delete an exercise by id
  Future<void> deleteExercise(int id) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // WORKOUT CRUD
  // ---------------------------------------------------------------------------

  /// Insert a new workout session (returns the new id)
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Insert a list of WorkoutExercise entries for a given workout
  Future<void> insertWorkoutExercises(
      List<WorkoutExercise> exercises) async {
    final db = await database;
    final batch = db.batch();
    for (final e in exercises) {
      batch.insert('workout_exercises', e.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Fetch all workouts ordered by most recent first
  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final maps =
        await db.query('workouts', orderBy: 'date DESC');
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  /// Fetch a single workout with its exercises
  Future<Workout?> getWorkoutWithExercises(int id) async {
    final db = await database;

    final workoutMaps =
        await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (workoutMaps.isEmpty) return null;

    final workout = Workout.fromMap(workoutMaps.first);

    final exerciseMaps = await db.query(
      'workout_exercises',
      where: 'workout_id = ?',
      whereArgs: [id],
    );

    final exercises =
        exerciseMaps.map((m) => WorkoutExercise.fromMap(m)).toList();

    return workout.copyWith(exercises: exercises);
  }

  /// Update an existing workout record
  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update('workouts', workout.toMap(),
        where: 'id = ?', whereArgs: [workout.id]);
  }

  /// Delete a workout and its associated exercises (cascade)
  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('workout_exercises', where: 'workout_id = ?', whereArgs: [id]);
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  /// Get total workouts logged (used for streak/stats)
  Future<int> getTotalWorkouts() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM workouts');
    return result.first['count'] as int;
  }

  /// Get workouts within a date range (yyyy-MM-dd strings)
  Future<List<Workout>> getWorkoutsBetween(
      String startDate, String endDate) async {
    final db = await database;
    final maps = await db.query(
      'workouts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  /// Get last N workouts (used for AI suggestion)
  Future<List<Workout>> getRecentWorkouts(int limit) async {
    final db = await database;
    final maps = await db.query(
      'workouts',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  /// Get workout count per day for the last N days (for chart data)
  Future<Map<String, int>> getWorkoutCountByDate(int days) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

    final maps = await db.rawQuery('''
      SELECT date, COUNT(*) as count
      FROM workouts
      WHERE date >= ?
      GROUP BY date
      ORDER BY date ASC
    ''', [cutoffStr]);

    final result = <String, int>{};
    for (final row in maps) {
      result[row['date'] as String] = row['count'] as int;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // QUEST CRUD
  // ---------------------------------------------------------------------------

  /// Insert a new quest
  Future<int> insertQuest(Quest quest) async {
    final db = await database;
    return await db.insert('quests', quest.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all quests
  Future<List<Quest>> getQuests() async {
    final db = await database;
    final maps =
        await db.query('quests', orderBy: 'is_completed ASC, id DESC');
    return maps.map((m) => Quest.fromMap(m)).toList();
  }

  /// Update quest progress and completion status
  Future<void> updateQuest(Quest quest) async {
    final db = await database;
    await db.update('quests', quest.toMap(),
        where: 'id = ?', whereArgs: [quest.id]);
  }

  /// Delete a quest by id
  Future<void> deleteQuest(int id) async {
    final db = await database;
    await db.delete('quests', where: 'id = ?', whereArgs: [id]);
  }

  /// Increment completed_workouts for all active quests (called when a workout is logged)
  Future<void> progressActiveQuests() async {
    final db = await database;

    // Get all non-completed quests
    final maps = await db.query('quests',
        where: 'is_completed = 0');
    final quests = maps.map((m) => Quest.fromMap(m)).toList();

    final batch = db.batch();
    for (final q in quests) {
      final updated = q.completedWorkouts + 1;
      final completed = updated >= q.targetWorkouts ? 1 : 0;
      batch.update(
        'quests',
        {'completed_workouts': updated, 'is_completed': completed},
        where: 'id = ?',
        whereArgs: [q.id],
      );
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // STREAK CALCULATION
  // ---------------------------------------------------------------------------

  /// Calculate the current consecutive-day workout streak
  Future<int> getCurrentStreak() async {
    final db = await database;
    final maps = await db.rawQuery(
        'SELECT DISTINCT date FROM workouts ORDER BY date DESC');

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime current = DateTime.now();

    for (final row in maps) {
      final dateStr = row['date'] as String;
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

      final diff = current
          .difference(date)
          .inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        current = date;
      } else {
        break;
      }
    }

    return streak;
  }

  // ---------------------------------------------------------------------------
  // DATABASE MAINTENANCE
  // ---------------------------------------------------------------------------

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  // ---------------------------------------------------------------------------
  // SEED DATA
  // ---------------------------------------------------------------------------

  Future<void> _seedExercises(Database db) async {
    final exercises = [
      // Chest
      {'name': 'Bench Press', 'category': 'Chest', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Lie on a bench and press a barbell upward from chest level. Classic compound push movement.', 'is_custom': 0},
      {'name': 'Push-Up', 'category': 'Chest', 'difficulty': 'Beginner', 'equipment': 'Bodyweight', 'description': 'Start in plank position, lower your chest to the floor, then push back up. Great for building chest and tricep strength.', 'is_custom': 0},
      {'name': 'Dumbbell Flyes', 'category': 'Chest', 'difficulty': 'Intermediate', 'equipment': 'Dumbbells', 'description': 'Lie on a bench with dumbbells, open arms wide then bring them together in an arc over your chest.', 'is_custom': 0},
      {'name': 'Incline Bench Press', 'category': 'Chest', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Same as bench press but on an inclined bench to target upper chest.', 'is_custom': 0},
      {'name': 'Cable Crossover', 'category': 'Chest', 'difficulty': 'Intermediate', 'equipment': 'Cable', 'description': 'Pull cable handles from high to low in a crossing motion to isolate the chest.', 'is_custom': 0},
      // Back
      {'name': 'Pull-Up', 'category': 'Back', 'difficulty': 'Intermediate', 'equipment': 'Bodyweight', 'description': 'Hang from a bar and pull your body up until your chin clears the bar. Excellent for lats and upper back.', 'is_custom': 0},
      {'name': 'Barbell Row', 'category': 'Back', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Bend at the hips and row a barbell up to your lower chest. Builds thickness in the upper back.', 'is_custom': 0},
      {'name': 'Lat Pulldown', 'category': 'Back', 'difficulty': 'Beginner', 'equipment': 'Machine', 'description': 'Pull a bar down to your upper chest while seated. Good lat isolation exercise.', 'is_custom': 0},
      {'name': 'Seated Cable Row', 'category': 'Back', 'difficulty': 'Beginner', 'equipment': 'Cable', 'description': 'Sit at a cable row station and pull the handle to your midsection while keeping your back straight.', 'is_custom': 0},
      {'name': 'Deadlift', 'category': 'Back', 'difficulty': 'Advanced', 'equipment': 'Barbell', 'description': 'Lift a loaded barbell from the floor to hip level. The king of posterior chain exercises.', 'is_custom': 0},
      // Legs
      {'name': 'Squat', 'category': 'Legs', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Place a barbell on your upper back and squat down until thighs are parallel to the floor. Fundamental lower-body movement.', 'is_custom': 0},
      {'name': 'Leg Press', 'category': 'Legs', 'difficulty': 'Beginner', 'equipment': 'Machine', 'description': 'Push a weighted platform away with your feet on a leg press machine. Targets quads, hamstrings, and glutes.', 'is_custom': 0},
      {'name': 'Lunges', 'category': 'Legs', 'difficulty': 'Beginner', 'equipment': 'Bodyweight', 'description': 'Step forward and lower your rear knee toward the floor, then return to standing. Great unilateral leg exercise.', 'is_custom': 0},
      {'name': 'Romanian Deadlift', 'category': 'Legs', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Hinge at the hips with a slight knee bend, lowering the bar along your legs. Targets hamstrings and glutes.', 'is_custom': 0},
      {'name': 'Calf Raise', 'category': 'Legs', 'difficulty': 'Beginner', 'equipment': 'Machine', 'description': 'Rise up on your toes against resistance to target the calf muscles.', 'is_custom': 0},
      // Shoulders
      {'name': 'Overhead Press', 'category': 'Shoulders', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Press a barbell overhead from shoulder height. The primary shoulder builder.', 'is_custom': 0},
      {'name': 'Lateral Raise', 'category': 'Shoulders', 'difficulty': 'Beginner', 'equipment': 'Dumbbells', 'description': 'Raise dumbbells out to the sides to shoulder height. Targets the medial deltoid.', 'is_custom': 0},
      {'name': 'Front Raise', 'category': 'Shoulders', 'difficulty': 'Beginner', 'equipment': 'Dumbbells', 'description': 'Raise dumbbells in front of you to shoulder height to target the anterior deltoid.', 'is_custom': 0},
      // Arms
      {'name': 'Barbell Curl', 'category': 'Arms', 'difficulty': 'Beginner', 'equipment': 'Barbell', 'description': 'Curl a barbell from hip level to shoulder height. Classic bicep builder.', 'is_custom': 0},
      {'name': 'Tricep Dip', 'category': 'Arms', 'difficulty': 'Intermediate', 'equipment': 'Bodyweight', 'description': 'Support yourself on parallel bars and lower/raise your body by bending the elbows. Great tricep compound movement.', 'is_custom': 0},
      {'name': 'Hammer Curl', 'category': 'Arms', 'difficulty': 'Beginner', 'equipment': 'Dumbbells', 'description': 'Curl dumbbells with a neutral (hammer) grip. Targets brachialis and brachioradialis.', 'is_custom': 0},
      {'name': 'Skull Crusher', 'category': 'Arms', 'difficulty': 'Intermediate', 'equipment': 'Barbell', 'description': 'Lower a barbell toward your forehead while lying on a bench. Excellent tricep isolation.', 'is_custom': 0},
      // Core
      {'name': 'Plank', 'category': 'Core', 'difficulty': 'Beginner', 'equipment': 'Bodyweight', 'description': 'Hold a push-up position on your forearms for time. Builds core stability and endurance.', 'is_custom': 0},
      {'name': 'Crunches', 'category': 'Core', 'difficulty': 'Beginner', 'equipment': 'Bodyweight', 'description': 'Lie on your back and curl your shoulders toward your knees. Targets the rectus abdominis.', 'is_custom': 0},
      {'name': 'Leg Raise', 'category': 'Core', 'difficulty': 'Intermediate', 'equipment': 'Bodyweight', 'description': 'Lie flat and raise straight legs to 90 degrees. Targets lower abs and hip flexors.', 'is_custom': 0},
      {'name': 'Russian Twist', 'category': 'Core', 'difficulty': 'Beginner', 'equipment': 'Bodyweight', 'description': 'Sit on the floor and rotate your torso side to side. Builds rotational core strength.', 'is_custom': 0},
      // Cardio
      {'name': 'Running', 'category': 'Cardio', 'difficulty': 'Beginner', 'equipment': 'None', 'description': 'Sustained aerobic running. Track distance and duration to monitor cardiovascular improvement.', 'is_custom': 0},
      {'name': 'Jump Rope', 'category': 'Cardio', 'difficulty': 'Beginner', 'equipment': 'None', 'description': 'Skip rope for timed intervals. Excellent for cardio, coordination, and calorie burn.', 'is_custom': 0},
      {'name': 'Burpee', 'category': 'Cardio', 'difficulty': 'Intermediate', 'equipment': 'Bodyweight', 'description': 'A full-body movement combining a squat, plank, push-up, and jump. High intensity.', 'is_custom': 0},
      {'name': 'Cycling', 'category': 'Cardio', 'difficulty': 'Beginner', 'equipment': 'Machine', 'description': 'Ride a stationary or outdoor bike. Great low-impact cardio option.', 'is_custom': 0},
      // Full Body
      {'name': 'Kettlebell Swing', 'category': 'Full Body', 'difficulty': 'Intermediate', 'equipment': 'Kettlebell', 'description': 'Hinge at the hips and swing a kettlebell from between your legs to shoulder height. Explosive full-body power movement.', 'is_custom': 0},
      {'name': 'Clean and Press', 'category': 'Full Body', 'difficulty': 'Advanced', 'equipment': 'Barbell', 'description': 'Pull a barbell from the floor to shoulders then press overhead. Total-body compound lift.', 'is_custom': 0},
    ];

    final batch = db.batch();
    for (final e in exercises) {
      batch.insert('exercises', e);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedQuests(Database db) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final quests = [
      {
        'name': 'First Step',
        'description': 'Log your very first workout to get started on your fitness journey.',
        'target_workouts': 1,
        'completed_workouts': 0,
        'reward': 'Badge: Beginner Athlete',
        'is_completed': 0,
        'created_date': todayStr,
      },
      {
        'name': 'Week Warrior',
        'description': 'Log 5 workouts to prove you can stay consistent for a week.',
        'target_workouts': 5,
        'completed_workouts': 0,
        'reward': 'Badge: Week Warrior',
        'is_completed': 0,
        'created_date': todayStr,
      },
      {
        'name': 'Iron Will',
        'description': 'Complete 10 workouts and show your dedication to the grind.',
        'target_workouts': 10,
        'completed_workouts': 0,
        'reward': 'Badge: Iron Will',
        'is_completed': 0,
        'created_date': todayStr,
      },
      {
        'name': 'Strength Builder',
        'description': 'Log 3 high-intensity strength workouts to build serious muscle.',
        'target_workouts': 3,
        'completed_workouts': 0,
        'reward': 'Badge: Power Lifter',
        'is_completed': 0,
        'created_date': todayStr,
      },
    ];

    final batch = db.batch();
    for (final q in quests) {
      batch.insert('quests', q);
    }
    await batch.commit(noResult: true);
  }
}

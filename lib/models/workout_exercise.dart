/// Represents a single exercise entry within a logged workout session.
/// Links a Workout to an Exercise with performance data (sets, reps, weight).
class WorkoutExercise {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final String exerciseName; // Denormalized for easy display
  final int sets;
  final int reps;
  final double weight; // in lbs; 0 if bodyweight
  final String notes;

  const WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight = 0.0,
    this.notes = '',
  });

  /// Convert to a map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
    };
  }

  /// Create a WorkoutExercise from a SQLite map
  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      exerciseId: map['exercise_id'] as int,
      exerciseName: map['exercise_name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }

  WorkoutExercise copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }

  /// Total volume for this exercise entry (sets * reps * weight)
  double get volume => sets * reps * (weight > 0 ? weight : 1);
}

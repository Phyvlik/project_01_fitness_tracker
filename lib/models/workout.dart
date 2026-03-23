import 'workout_exercise.dart';

/// Represents a logged workout session.
class Workout {
  final int? id;
  final String name;
  final String date; // ISO 8601 date string (yyyy-MM-dd)
  final int duration; // in minutes
  final String notes;
  final String intensity; // Low, Medium, High
  final int? questId; // optional link to a Quest
  final List<WorkoutExercise> exercises; // loaded separately from DB

  const Workout({
    this.id,
    required this.name,
    required this.date,
    required this.duration,
    this.notes = '',
    required this.intensity,
    this.questId,
    this.exercises = const [],
  });

  /// Convert to a map for SQLite insertion (does NOT include exercises list)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'duration': duration,
      'notes': notes,
      'intensity': intensity,
      'quest_id': questId,
    };
  }

  /// Create a Workout from a SQLite map (exercises loaded separately)
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: map['date'] as String,
      duration: map['duration'] as int,
      notes: map['notes'] as String? ?? '',
      intensity: map['intensity'] as String,
      questId: map['quest_id'] as int?,
      exercises: const [],
    );
  }

  Workout copyWith({
    int? id,
    String? name,
    String? date,
    int? duration,
    String? notes,
    String? intensity,
    int? questId,
    List<WorkoutExercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      intensity: intensity ?? this.intensity,
      questId: questId ?? this.questId,
      exercises: exercises ?? this.exercises,
    );
  }

  /// Total volume across all exercises in this session
  double get totalVolume =>
      exercises.fold(0.0, (sum, e) => sum + e.volume);

  static const List<String> intensityLevels = ['Low', 'Medium', 'High'];
}

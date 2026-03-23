/// Represents a fitness quest/challenge that motivates users to hit workout goals.
class Quest {
  final int? id;
  final String name;
  final String description;
  final int targetWorkouts; // number of workouts needed to complete
  final int completedWorkouts; // progress so far
  final String reward; // reward message shown on completion
  final bool isCompleted;
  final String createdDate; // ISO 8601

  const Quest({
    this.id,
    required this.name,
    required this.description,
    required this.targetWorkouts,
    this.completedWorkouts = 0,
    required this.reward,
    this.isCompleted = false,
    required this.createdDate,
  });

  /// Completion percentage (0.0 – 1.0)
  double get progress =>
      targetWorkouts > 0 ? (completedWorkouts / targetWorkouts).clamp(0.0, 1.0) : 0.0;

  /// Convert to a map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_workouts': targetWorkouts,
      'completed_workouts': completedWorkouts,
      'reward': reward,
      'is_completed': isCompleted ? 1 : 0,
      'created_date': createdDate,
    };
  }

  /// Create a Quest from a SQLite map
  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      targetWorkouts: map['target_workouts'] as int,
      completedWorkouts: map['completed_workouts'] as int,
      reward: map['reward'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      createdDate: map['created_date'] as String,
    );
  }

  Quest copyWith({
    int? id,
    String? name,
    String? description,
    int? targetWorkouts,
    int? completedWorkouts,
    String? reward,
    bool? isCompleted,
    String? createdDate,
  }) {
    return Quest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetWorkouts: targetWorkouts ?? this.targetWorkouts,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

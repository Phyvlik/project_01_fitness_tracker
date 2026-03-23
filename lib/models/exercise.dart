/// Represents an exercise in the exercise library.
/// Exercises can be predefined or user-created (custom).
class Exercise {
  final int? id;
  final String name;
  final String category; // e.g. Chest, Back, Legs, Shoulders, Arms, Core, Cardio
  final String difficulty; // Beginner, Intermediate, Advanced
  final String equipment; // Bodyweight, Dumbbells, Barbell, Machine, Cable, None
  final String description;
  final bool isCustom; // true if user-created

  const Exercise({
    this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.equipment,
    required this.description,
    this.isCustom = false,
  });

  /// Convert to a map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'equipment': equipment,
      'description': description,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  /// Create an Exercise from a SQLite map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      difficulty: map['difficulty'] as String,
      equipment: map['equipment'] as String,
      description: map['description'] as String,
      isCustom: (map['is_custom'] as int) == 1,
    );
  }

  /// Returns a copy with optional field overrides
  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? difficulty,
    String? equipment,
    String? description,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  static const List<String> categories = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
    'Full Body',
  ];

  static const List<String> difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static const List<String> equipmentOptions = [
    'Bodyweight',
    'Dumbbells',
    'Barbell',
    'Machine',
    'Cable',
    'Resistance Band',
    'Kettlebell',
    'None',
  ];
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/workout.dart';
import '../models/quest.dart';

/// Central state provider for the app.
/// Manages theme, workout list, quests, streaks, and AI suggestions.
/// Uses SharedPreferences for persistent settings and SQLite for workout data.
class AppProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // ---------------------------------------------------------------------------
  // Workout state
  // ---------------------------------------------------------------------------
  List<Workout> _workouts = [];
  List<Workout> get workouts => List.unmodifiable(_workouts);

  bool _isLoadingWorkouts = false;
  bool get isLoadingWorkouts => _isLoadingWorkouts;

  // ---------------------------------------------------------------------------
  // Quest state
  // ---------------------------------------------------------------------------
  List<Quest> _quests = [];
  List<Quest> get quests => List.unmodifiable(_quests);

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int get totalWorkouts => _workouts.length;

  int get weeklyWorkouts {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _workouts.where((w) {
      final parts = w.date.split('-');
      if (parts.length != 3) return false;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return d.isAfter(weekAgo);
    }).length;
  }

  // ---------------------------------------------------------------------------
  // AI Suggestion (local rule-based)
  // ---------------------------------------------------------------------------
  String _aiSuggestion = '';
  String get aiSuggestion => _aiSuggestion;

  String _aiReason = '';
  String get aiReason => _aiReason;

  int _aiHelpfulCount = 0;
  int get aiHelpfulCount => _aiHelpfulCount;

  int _aiNotHelpfulCount = 0;
  int get aiNotHelpfulCount => _aiNotHelpfulCount;

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  /// Load persisted settings and initial data. Call once in main.dart.
  Future<void> init() async {
    await _loadSettings();
    await loadWorkouts();
    await loadQuests();
    await _refreshStreak();
    _generateAiSuggestion();
  }

  // ---------------------------------------------------------------------------
  // Settings (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const _keyDarkMode = 'dark_mode';
  static const _keyWeeklyGoal = 'weekly_goal';
  static const _keyWeightUnit = 'weight_unit';
  static const _keyNotifications = 'notifications_enabled';
  static const _keyAiHelpfulCount = 'ai_helpful_count';
  static const _keyAiNotHelpfulCount = 'ai_not_helpful_count';

  int _weeklyGoal = 4;
  int get weeklyGoal => _weeklyGoal;

  String _weightUnit = 'lbs'; // 'lbs' or 'kg'
  String get weightUnit => _weightUnit;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    _weeklyGoal = prefs.getInt(_keyWeeklyGoal) ?? 4;
    _weightUnit = prefs.getString(_keyWeightUnit) ?? 'lbs';
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _aiHelpfulCount = prefs.getInt(_keyAiHelpfulCount) ?? 0;
    _aiNotHelpfulCount = prefs.getInt(_keyAiNotHelpfulCount) ?? 0;
    notifyListeners();
  }

  Future<void> recordAiFeedback(bool helpful) async {
    final prefs = await SharedPreferences.getInstance();
    if (helpful) {
      _aiHelpfulCount++;
      await prefs.setInt(_keyAiHelpfulCount, _aiHelpfulCount);
    } else {
      _aiNotHelpfulCount++;
      await prefs.setInt(_keyAiNotHelpfulCount, _aiNotHelpfulCount);
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklyGoal, goal);
    notifyListeners();
  }

  Future<void> setWeightUnit(String unit) async {
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeightUnit, unit);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, _notificationsEnabled);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Workout operations
  // ---------------------------------------------------------------------------

  Future<void> loadWorkouts() async {
    _isLoadingWorkouts = true;
    notifyListeners();

    _workouts = await DatabaseHelper.instance.getWorkouts();
    _isLoadingWorkouts = false;
    notifyListeners();
  }

  /// Save a new workout and its exercises, then refresh state.
  Future<void> addWorkout(Workout workout) async {
    // Insert workout record
    final id = await DatabaseHelper.instance.insertWorkout(workout);

    // Attach the new id to each exercise entry and insert them
    if (workout.exercises.isNotEmpty) {
      final linked = workout.exercises
          .map((e) => e.copyWith(workoutId: id))
          .toList();
      await DatabaseHelper.instance.insertWorkoutExercises(linked);
    }

    // Advance all active quests
    await DatabaseHelper.instance.progressActiveQuests();

    // Refresh state
    await loadWorkouts();
    await loadQuests();
    await _refreshStreak();
    _generateAiSuggestion();
  }

  /// Delete a workout by id, then refresh state.
  Future<void> deleteWorkout(int id) async {
    await DatabaseHelper.instance.deleteWorkout(id);
    await loadWorkouts();
    await _refreshStreak();
    _generateAiSuggestion();
  }

  // ---------------------------------------------------------------------------
  // Quest operations
  // ---------------------------------------------------------------------------

  Future<void> loadQuests() async {
    _quests = await DatabaseHelper.instance.getQuests();
    notifyListeners();
  }

  Future<void> addQuest(Quest quest) async {
    await DatabaseHelper.instance.insertQuest(quest);
    await loadQuests();
  }

  Future<void> deleteQuest(int id) async {
    await DatabaseHelper.instance.deleteQuest(id);
    await loadQuests();
  }

  // ---------------------------------------------------------------------------
  // Streak
  // ---------------------------------------------------------------------------

  Future<void> _refreshStreak() async {
    _currentStreak = await DatabaseHelper.instance.getCurrentStreak();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // AI Suggestion (local rule-based)
  // ---------------------------------------------------------------------------

  /// Analyzes the last 5 workouts and produces a recovery/intensity suggestion.
  /// "Based on your last X sessions" style explanation makes the logic transparent.
  void _generateAiSuggestion() {
    if (_workouts.isEmpty) {
      _aiSuggestion =
          'Log your first workout to get a personalized recommendation!';
      _aiReason = 'No workout history yet.';
      notifyListeners();
      return;
    }

    final recent = _workouts.take(5).toList();

    // Count consecutive high-intensity sessions
    int consecutiveHigh = 0;
    for (final w in recent) {
      if (w.intensity == 'High') {
        consecutiveHigh++;
      } else {
        break;
      }
    }

    // Count recent intensity distribution
    final highCount = recent.where((w) => w.intensity == 'High').length;
    final lowCount = recent.where((w) => w.intensity == 'Low').length;

    // Check days since last workout
    final lastDate = _parseDate(recent.first.date);
    final daysSince = DateTime.now().difference(lastDate).inDays;

    if (consecutiveHigh >= 2) {
      // Recommend recovery after back-to-back high intensity
      _aiSuggestion = 'Rest day or Light Recovery Session';
      _aiReason =
          'Based on your last $consecutiveHigh high-intensity sessions, your muscles need recovery time. Consider a walk, stretch, or yoga to stay active without overtraining.';
    } else if (daysSince >= 3) {
      // Been a while — motivate them back
      _aiSuggestion = 'Medium Intensity Full-Body Workout';
      _aiReason =
          "It's been $daysSince days since your last workout. Ease back in with a moderate full-body session to rebuild momentum.";
    } else if (lowCount >= 3) {
      // Too many easy workouts — push harder
      _aiSuggestion = 'High Intensity Strength Training';
      _aiReason =
          'Based on your last ${recent.length} sessions ($lowCount were low intensity), it\'s time to push harder for better results.';
    } else if (highCount == 0) {
      _aiSuggestion = 'Increase Intensity This Session';
      _aiReason =
          'Your recent workouts have all been low to medium intensity. Add a challenging set or heavier weight today.';
    } else {
      // Balanced — suggest rotating muscle groups based on last workout name
      _aiSuggestion = 'Balanced Moderate Workout';
      _aiReason =
          'Based on your last ${recent.length} sessions, you\'re maintaining a good balance. Keep it up!';
    }

    notifyListeners();
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Exports workouts and quests to a JSON file in local app storage.
  /// Returns the absolute file path for user confirmation in UI.
  Future<String> exportDataToJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/fitness_tracker_export_$stamp.json');

    final payload = {
      'exported_at': now.toIso8601String(),
      'workouts': _workouts
          .map(
            (w) => {
              'id': w.id,
              'name': w.name,
              'date': w.date,
              'duration': w.duration,
              'notes': w.notes,
              'intensity': w.intensity,
            },
          )
          .toList(),
      'quests': _quests
          .map(
            (q) => {
              'id': q.id,
              'name': q.name,
              'description': q.description,
              'target_workouts': q.targetWorkouts,
              'completed_workouts': q.completedWorkouts,
              'reward': q.reward,
              'is_completed': q.isCompleted,
              'created_date': q.createdDate,
            },
          )
          .toList(),
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return file.path;
  }

  /// Imports workouts and quests from JSON content produced by exportDataToJson.
  /// Returns import counts for UI feedback.
  Future<Map<String, int>> importDataFromJsonString(String jsonContent) async {
    final raw = jsonDecode(jsonContent);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON root format');
    }

    final workoutsRaw = (raw['workouts'] as List?) ?? const [];
    final questsRaw = (raw['quests'] as List?) ?? const [];

    int workoutsImported = 0;
    int questsImported = 0;

    for (final item in workoutsRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final workout = Workout(
        name: (map['name'] ?? '').toString().trim(),
        date: (map['date'] ?? '').toString().trim(),
        duration: (map['duration'] as num?)?.toInt() ?? 0,
        notes: (map['notes'] ?? '').toString(),
        intensity: (map['intensity'] ?? 'Medium').toString(),
      );

      if (workout.name.isEmpty ||
          workout.date.isEmpty ||
          workout.duration <= 0) {
        continue;
      }

      await DatabaseHelper.instance.insertWorkout(workout);
      workoutsImported++;
    }

    for (final item in questsRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final quest = Quest(
        name: (map['name'] ?? '').toString().trim(),
        description: (map['description'] ?? '').toString().trim(),
        targetWorkouts: (map['target_workouts'] as num?)?.toInt() ?? 0,
        completedWorkouts: (map['completed_workouts'] as num?)?.toInt() ?? 0,
        reward: (map['reward'] ?? '').toString().trim(),
        isCompleted: map['is_completed'] == true || map['is_completed'] == 1,
        createdDate: (map['created_date'] ?? DateTime.now().toIso8601String())
            .toString(),
      );

      if (quest.name.isEmpty || quest.targetWorkouts <= 0) {
        continue;
      }

      await DatabaseHelper.instance.insertQuest(quest);
      questsImported++;
    }

    await loadWorkouts();
    await loadQuests();
    await _refreshStreak();
    _generateAiSuggestion();

    return {'workouts': workoutsImported, 'quests': questsImported};
  }
}

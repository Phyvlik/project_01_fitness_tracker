import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../models/exercise.dart';
import '../providers/app_provider.dart';
import '../db/database_helper.dart';

/// Screen for logging a new workout session.
/// Users enter the workout name, date, duration, intensity, notes,
/// and add exercises with sets/reps/weight.
class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedIntensity = 'Medium';
  DateTime _selectedDate = DateTime.now();

  // Exercises added to this session
  final List<WorkoutExercise> _sessionExercises = [];

  bool _isSaving = false;

  // Normalizes user-entered text before persisting to SQLite.
  String _sanitizeText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Formats a DateTime object to ISO 8601 format (yyyy-MM-dd)
  /// Used for database storage and consistency across the app
  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Opens a date picker and updates the selected date if user confirms
  /// Only allows dates from 2020 to today (cannot log future workouts)
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Opens the exercise picker sheet and adds the chosen exercise
  Future<void> _addExercise() async {
    final exercises = await DatabaseHelper.instance.getExercises();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExercisePickerSheet(
        exercises: exercises,
        onSelected: (exercise) {
          _showExerciseDetailsDialog(exercise);
        },
      ),
    );
  }

  /// Dialog to enter sets/reps/weight for a selected exercise
  void _showExerciseDetailsDialog(Exercise exercise) {
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '0');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumberField(setsCtrl, 'Sets', Icons.repeat),
              const SizedBox(height: 12),
              _buildNumberField(repsCtrl, 'Reps', Icons.repeat_one),
              const SizedBox(height: 12),
              _buildNumberField(
                weightCtrl,
                'Weight (lbs)',
                Icons.monitor_weight_outlined,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final sets = int.tryParse(setsCtrl.text) ?? 3;
              final reps = int.tryParse(repsCtrl.text) ?? 10;
              final weight = double.tryParse(weightCtrl.text) ?? 0.0;

              if (sets <= 0 || reps <= 0 || weight < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sets and reps must be greater than 0, weight cannot be negative.',
                    ),
                  ),
                );
                return;
              }

              setState(() {
                _sessionExercises.add(
                  WorkoutExercise(
                    workoutId: 0, // placeholder — set on save
                    exerciseId: exercise.id!,
                    exerciseName: exercise.name,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                    notes: _sanitizeText(notesCtrl.text),
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Builds a reusable text field for numeric input (sets, reps, weight)
  /// Supports decimal input for weight values
  /// Parameters: controller (editable text), label (field name), icon (visual indicator)
  Widget _buildNumberField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    if (duration <= 0 || duration > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duration must be between 1 and 600 minutes.'),
        ),
      );
      return;
    }

    if (_sessionExercises.isEmpty) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save without exercises?'),
          content: const Text(
            'This workout has no exercises. Do you want to save it anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save Anyway'),
            ),
          ],
        ),
      );

      if (shouldSave != true) return;
    }

    setState(() => _isSaving = true);

    final workout = Workout(
      name: _sanitizeText(_nameController.text),
      date: _formatDate(_selectedDate),
      duration: duration,
      notes: _sanitizeText(_notesController.text),
      intensity: _selectedIntensity,
      exercises: _sessionExercises,
    );

    await context.read<AppProvider>().addWorkout(workout);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveWorkout, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Workout name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Workout Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
                hintText: 'e.g. Morning Push Day',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 16),

            // Date picker row
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(_formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                hintText: 'e.g. 45',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter duration';
                if (int.tryParse(v) == null) return 'Enter a valid number';
                final parsed = int.parse(v);
                if (parsed <= 0 || parsed > 600) {
                  return 'Use a value between 1 and 600';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Intensity selector
            Text('Intensity', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: Workout.intensityLevels
                  .map(
                    (level) => ButtonSegment<String>(
                      value: level,
                      label: Text(level),
                      icon: Icon(_intensityIcon(level)),
                    ),
                  )
                  .toList(),
              selected: {_selectedIntensity},
              onSelectionChanged: (s) =>
                  setState(() => _selectedIntensity = s.first),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                hintText: 'How did it feel? Any PRs?',
              ),
            ),
            const SizedBox(height: 24),

            // Exercises section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _addExercise,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 4),
                      Text('Add Exercise'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_sessionExercises.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No exercises added yet.\nTap "Add Exercise" to get started.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_sessionExercises.length, (i) {
                final ex = _sessionExercises[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(ex.exerciseName),
                    subtitle: Text(
                      '${ex.sets} sets × ${ex.reps} reps'
                      '${ex.weight > 0 ? ' @ ${ex.weight} lbs' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          setState(() => _sessionExercises.removeAt(i)),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  IconData _intensityIcon(String intensity) {
    switch (intensity) {
      case 'High':
        return Icons.local_fire_department;
      case 'Medium':
        return Icons.fitness_center;
      default:
        return Icons.self_improvement;
    }
  }
}

// ---------------------------------------------------------------------------
// Exercise picker bottom sheet
// ---------------------------------------------------------------------------

class _ExercisePickerSheet extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise) onSelected;

  const _ExercisePickerSheet({
    required this.exercises,
    required this.onSelected,
  });

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _search = '';
  String _filterCategory = '';
  String _filterDifficulty = '';
  String _filterEquipment = '';

  List<Exercise> get _filtered => widget.exercises.where((e) {
    final matchSearch =
        _search.isEmpty || e.name.toLowerCase().contains(_search.toLowerCase());
    final matchCat = _filterCategory.isEmpty || e.category == _filterCategory;
    final matchDifficulty =
        _filterDifficulty.isEmpty || e.difficulty == _filterDifficulty;
    final matchEquipment =
        _filterEquipment.isEmpty || e.equipment == _filterEquipment;
    return matchSearch && matchCat && matchDifficulty && matchEquipment;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['', ...Exercise.categories];
    final difficulties = ['', ...Exercise.difficulties];
    final equipment = ['', ...Exercise.equipmentOptions];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select Exercise',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Search field
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            // Category filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final label = cat.isEmpty ? 'All' : cat;
                  final selected = _filterCategory == cat;
                  return FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: difficulties
                        .map(
                          (d) => DropdownMenuItem<String>(
                            value: d,
                            child: Text(d.isEmpty ? 'All' : d),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _filterDifficulty = v ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterEquipment,
                    decoration: const InputDecoration(
                      labelText: 'Equipment',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: equipment
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e.isEmpty ? 'All' : e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _filterEquipment = v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Exercise list
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final ex = _filtered[i];
                  return ListTile(
                    title: Text(ex.name),
                    subtitle: Text(
                      '${ex.category} · ${ex.difficulty} · ${ex.equipment}',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelected(ex);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/workout_card.dart';
import '../db/database_helper.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';

/// Displays the full workout history list with search and filtering.
/// Users can swipe to delete workouts or tap to view details.
class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  String _searchQuery = '';
  String _filterIntensity = '';

  List<Workout> _applyFilters(List<Workout> workouts) {
    return workouts.where((w) {
      final matchSearch =
          _searchQuery.isEmpty ||
          w.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchIntensity =
          _filterIntensity.isEmpty || w.intensity == _filterIntensity;
      return matchSearch && matchIntensity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final filtered = _applyFilters(provider.workouts);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout Log'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search workouts...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Intensity filter chips
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['', 'Low', 'Medium', 'High'].map((level) {
                          final label = level.isEmpty ? 'All' : level;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(label),
                              selected: _filterIntensity == level,
                              onSelected: (_) =>
                                  setState(() => _filterIntensity = level),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: provider.isLoadingWorkouts
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.workouts.isEmpty
                            ? 'No workouts logged yet.'
                            : 'No workouts match your search.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final workout = filtered[i];
                    return WorkoutCard(
                      workout: workout,
                      onTap: () => _showWorkoutDetails(ctx, workout),
                      onDelete: () => provider.deleteWorkout(workout.id!),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Log Workout'),
          ),
        );
      },
    );
  }

  Future<void> _showWorkoutDetails(
    BuildContext context,
    Workout workout,
  ) async {
    // Load exercises for this workout
    final full = await DatabaseHelper.instance.getWorkoutWithExercises(
      workout.id!,
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkoutDetailSheet(workout: full ?? workout),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout detail bottom sheet
// ---------------------------------------------------------------------------

class _WorkoutDetailSheet extends StatelessWidget {
  final Workout workout;

  const _WorkoutDetailSheet({required this.workout});

  Color _intensityColor(String intensity) {
    switch (intensity) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensityColor = _intensityColor(workout.intensity);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: ListView(
          controller: scrollCtrl,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title and intensity
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: intensityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    workout.intensity,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: intensityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Meta info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  workout.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${workout.duration} min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (workout.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(workout.notes)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (workout.exercises.isNotEmpty) ...[
              Text(
                'Exercises',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...workout.exercises.map(
                (ex) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(ex.exerciseName),
                  subtitle: Text(
                    '${ex.sets} sets × ${ex.reps} reps'
                    '${ex.weight > 0 ? ' @ ${ex.weight} lbs' : ''}',
                  ),
                ),
              ),
            ] else
              Center(
                child: Text(
                  'No exercises recorded.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

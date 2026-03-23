import 'package:flutter/material.dart';
import '../models/workout.dart';

/// Card widget that displays a workout session summary in the history list.
/// Supports swipe-to-delete via the onDelete callback.
class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.onDelete,
  });

  Color _intensityColor(String intensity, ColorScheme scheme) {
    switch (intensity) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensityColor = _intensityColor(
      workout.intensity,
      theme.colorScheme,
    );

    return Dismissible(
      key: Key('workout_${workout.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        // Show confirmation dialog before deleting
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Workout'),
            content: Text('Delete "${workout.name}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Semantics(
        label:
            'Workout ${workout.name}, ${workout.intensity} intensity, ${workout.duration} minutes, on ${workout.date}',
        hint: 'Tap for details. Swipe left to delete.',
        button: true,
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Intensity icon badge
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: intensityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _intensityIcon(workout.intensity),
                      color: intensityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name, date, duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout.date,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.duration} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Intensity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: intensityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      workout.intensity,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: intensityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

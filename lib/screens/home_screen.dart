import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/ai_suggestion_card.dart';
import '../widgets/workout_card.dart';
import 'workout_log_screen.dart';

/// Dashboard screen — the first thing users see.
/// Shows streak, weekly stats, AI suggestion, and recent workout history.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        final recentWorkouts = provider.workouts.take(5).toList();

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => provider.loadWorkouts(),
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  snap: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fitness Quest',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getGreeting(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.local_fire_department,
                              label: 'Day Streak',
                              value: '${provider.currentStreak}',
                              iconColor: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: Icons.fitness_center,
                              label: 'Total Workouts',
                              value: '${provider.totalWorkouts}',
                              iconColor: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: Icons.calendar_view_week,
                              label: 'This Week',
                              value: '${provider.weeklyWorkouts}',
                              iconColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Weekly goal progress
                      _WeeklyGoalBar(
                        current: provider.weeklyWorkouts,
                        goal: provider.weeklyGoal,
                      ),

                      const SizedBox(height: 20),

                      // AI suggestion card
                      AiSuggestionCard(
                        suggestion: provider.aiSuggestion,
                        reason: provider.aiReason,
                        helpfulCount: provider.aiHelpfulCount,
                        notHelpfulCount: provider.aiNotHelpfulCount,
                        onHelpful: () => provider.recordAiFeedback(true),
                        onNotHelpful: () => provider.recordAiFeedback(false),
                      ),

                      const SizedBox(height: 20),

                      // Recent workouts header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Workouts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.totalWorkouts > 5)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WorkoutLogScreen(),
                                  ),
                                );
                              },
                              child: const Text('See All'),
                            ),
                        ],
                      ),
                    ]),
                  ),
                ),

                // Recent workout cards
                if (provider.isLoadingWorkouts)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (recentWorkouts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 56, bottom: 120),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts yet!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to log your first workout.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final workout = recentWorkouts[index];
                      return WorkoutCard(
                        workout: workout,
                        onDelete: () => provider.deleteWorkout(workout.id!),
                      );
                    }, childCount: recentWorkouts.length),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! Ready to crush it?';
    if (hour < 17) return 'Good afternoon! Time to train.';
    return 'Good evening! Evening grind time.';
  }
}

/// Progress bar showing workouts completed vs weekly goal
class _WeeklyGoalBar extends StatelessWidget {
  final int current;
  final int goal;

  const _WeeklyGoalBar({required this.current, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= goal;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Goal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isComplete ? 'Goal Reached!' : '$current / $goal workouts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isComplete
                        ? Colors.green
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isComplete
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

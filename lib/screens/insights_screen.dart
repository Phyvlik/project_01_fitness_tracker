import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../providers/app_provider.dart';

/// Visual analytics page that summarizes trends from local workout history.
/// Built to satisfy responsive design and chart-based insights requirements.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<Map<String, int>> _trendFuture;

  @override
  void initState() {
    super.initState();
    _trendFuture = DatabaseHelper.instance.getWorkoutCountByDate(14);
  }

  Future<void> _refreshData() async {
    setState(() {
      _trendFuture = DatabaseHelper.instance.getWorkoutCountByDate(14);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            final cardsPerRow = isLandscape ? 4 : 2;

            return FutureBuilder<Map<String, int>>(
              future: _trendFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final trend = snapshot.data ?? <String, int>{};
                final chartSpots = _toSpots(trend);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Performance Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: cardsPerRow,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isLandscape ? 2.2 : 1.5,
                      children: [
                        _MetricTile(
                          label: 'Total Workouts',
                          value: '${provider.totalWorkouts}',
                          icon: Icons.fitness_center,
                        ),
                        _MetricTile(
                          label: 'Current Streak',
                          value: '${provider.currentStreak} days',
                          icon: Icons.local_fire_department,
                        ),
                        _MetricTile(
                          label: 'Weekly Progress',
                          value:
                              '${provider.weeklyWorkouts}/${provider.weeklyGoal}',
                          icon: Icons.calendar_view_week,
                        ),
                        _MetricTile(
                          label: 'Quest Progress',
                          value: _questSummary(provider),
                          icon: Icons.flag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last 14 Days Trend',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: chartSpots.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No trend data yet. Log workouts to see chart insights.',
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : LineChart(
                                      LineChartData(
                                        minY: 0,
                                        gridData: const FlGridData(show: true),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              reservedSize: 28,
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 28,
                                              interval: 3,
                                              getTitlesWidget: (value, meta) {
                                                if (value % 3 != 0) {
                                                  return const SizedBox.shrink();
                                                }
                                                return Text(
                                                  'D${value.toInt() + 1}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: chartSpots,
                                            isCurved: true,
                                            barWidth: 3,
                                            color: theme.colorScheme.primary,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _questSummary(AppProvider provider) {
    if (provider.quests.isEmpty) return '0 active';
    final completed = provider.quests.where((q) => q.isCompleted).length;
    return '$completed/${provider.quests.length} done';
  }

  List<FlSpot> _toSpots(Map<String, int> trend) {
    if (trend.isEmpty) return const [];

    final keys = trend.keys.toList()..sort();
    return List<FlSpot>.generate(
      keys.length,
      (index) => FlSpot(index.toDouble(), (trend[keys[index]] ?? 0).toDouble()),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

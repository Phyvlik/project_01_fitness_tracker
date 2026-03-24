import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../models/exercise.dart';
import '../providers/app_provider.dart';

/// Visual analytics page that summarizes trends from local workout history.
/// Built to satisfy responsive design and chart-based insights requirements.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<Map<String, double>> _trendFuture;

  String _selectedMetric = 'count';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTrend();
  }

  void _loadTrend() {
    _trendFuture = DatabaseHelper.instance.getTrendData(
      days: 14,
      metric: _selectedMetric,
      category: _selectedMetric == 'intensity' ? 'All' : _selectedCategory,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadTrend();
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

            return FutureBuilder<Map<String, double>>(
              future: _trendFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final trend = snapshot.data ?? <String, double>{};
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
                              'Trend Filters',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'count',
                                  label: Text('Count'),
                                  icon: Icon(Icons.calendar_today),
                                ),
                                ButtonSegment<String>(
                                  value: 'weight',
                                  label: Text('Weight'),
                                  icon: Icon(Icons.monitor_weight_outlined),
                                ),
                                ButtonSegment<String>(
                                  value: 'reps',
                                  label: Text('Reps'),
                                  icon: Icon(Icons.repeat),
                                ),
                                ButtonSegment<String>(
                                  value: 'intensity',
                                  label: Text('Intensity'),
                                  icon: Icon(Icons.local_fire_department),
                                ),
                              ],
                              selected: {_selectedMetric},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _selectedMetric = selection.first;
                                  if (_selectedMetric == 'intensity') {
                                    _selectedCategory = 'All';
                                  }
                                  _loadTrend();
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Workout Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text('All'),
                                ),
                                DropdownMenuItem(
                                  value: 'Chest',
                                  child: Text('Chest'),
                                ),
                                DropdownMenuItem(
                                  value: 'Back',
                                  child: Text('Back'),
                                ),
                                DropdownMenuItem(
                                  value: 'Legs',
                                  child: Text('Legs'),
                                ),
                                DropdownMenuItem(
                                  value: 'Shoulders',
                                  child: Text('Shoulders'),
                                ),
                                DropdownMenuItem(
                                  value: 'Arms',
                                  child: Text('Arms'),
                                ),
                                DropdownMenuItem(
                                  value: 'Core',
                                  child: Text('Core'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cardio',
                                  child: Text('Cardio'),
                                ),
                                DropdownMenuItem(
                                  value: 'Full Body',
                                  child: Text('Full Body'),
                                ),
                              ],
                              onChanged: _selectedMetric == 'intensity'
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _selectedCategory = value;
                                        _loadTrend();
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _chartTitle(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: chartSpots.every((spot) => spot.y == 0)
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
                                              reservedSize: 36,
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
                                            dotData:
                                                const FlDotData(show: true),
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

  String _chartTitle() {
    final metricLabel = switch (_selectedMetric) {
      'count' => 'Workout Count',
      'weight' => 'Weight Volume',
      'reps' => 'Total Reps',
      'intensity' => 'Average Intensity',
      _ => 'Trend',
    };

    final categoryLabel =
        _selectedMetric == 'intensity' ? 'All Workouts' : _selectedCategory;

    return 'Last 14 Days: $metricLabel ($categoryLabel)';
  }

  List<FlSpot> _toSpots(Map<String, double> trend) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final value = trend[key] ?? 0.0;
      spots.add(FlSpot((13 - i).toDouble(), value));
    }

    return spots;
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

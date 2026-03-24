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
  late Future<Map<String, double>> _trendFuture;

  String _selectedMetric = 'count';
  String _selectedCategory = 'All';
  int _selectedDays = 14;

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
      days: _selectedDays,
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
                final maxY = _getMaxY(chartSpots);
                final yInterval = _getYAxisInterval(maxY);

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
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedDays,
                              decoration: const InputDecoration(
                                labelText: 'Time Range',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 7,
                                  child: Text('Last 7 Days'),
                                ),
                                DropdownMenuItem(
                                  value: 14,
                                  child: Text('Last 14 Days'),
                                ),
                                DropdownMenuItem(
                                  value: 30,
                                  child: Text('Last Month'),
                                ),
                                DropdownMenuItem(
                                  value: 90,
                                  child: Text('Last 3 Months'),
                                ),
                                DropdownMenuItem(
                                  value: 180,
                                  child: Text('Last 6 Months'),
                                ),
                                DropdownMenuItem(
                                  value: 365,
                                  child: Text('Last Year'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedDays = value;
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
                                        maxY: maxY,
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
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: yInterval,
                                              reservedSize: 44,
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 28,
                                              interval: _bottomTitleInterval(),
                                              getTitlesWidget: (value, meta) {
                                                final x = value.toInt();

                                                if (x < 0 ||
                                                    x >= _selectedDays) {
                                                  return const SizedBox.shrink();
                                                }

                                                if (value %
                                                        _bottomTitleInterval() !=
                                                    0) {
                                                  return const SizedBox.shrink();
                                                }

                                                return Text(
                                                  'D${x + 1}',
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
                                            preventCurveOverShooting: true,
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
      'weight' => 'Average Weight',
      'reps' => 'Total Reps',
      'intensity' => 'Average Intensity',
      _ => 'Trend',
    };

    final categoryLabel =
        _selectedMetric == 'intensity' ? 'All Workouts' : _selectedCategory;

    return '${_rangeLabel()}: $metricLabel ($categoryLabel)';
  }

  String _rangeLabel() {
    switch (_selectedDays) {
      case 7:
        return 'Last 7 Days';
      case 14:
        return 'Last 14 Days';
      case 30:
        return 'Last Month';
      case 90:
        return 'Last 3 Months';
      case 180:
        return 'Last 6 Months';
      case 365:
        return 'Last Year';
      default:
        return 'Last $_selectedDays Days';
    }
  }

  double _bottomTitleInterval() {
    if (_selectedDays <= 7) return 1;
    if (_selectedDays <= 14) return 3;
    if (_selectedDays <= 30) return 5;
    if (_selectedDays <= 90) return 15;
    if (_selectedDays <= 180) return 30;
    return 60;
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 4;

    final highest = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);

    if (highest <= 0) return 4;

    if (_selectedMetric == 'count') {
      return (highest + 1).ceilToDouble();
    }

    if (_selectedMetric == 'intensity') {
      return 3;
    }

    if (_selectedMetric == 'reps') {
      if (highest <= 20) return 25;
      if (highest <= 50) return 60;
      if (highest <= 100) return 120;
      return ((highest / 25).ceil() * 25).toDouble();
    }

    if (_selectedMetric == 'weight') {
      if (highest <= 50) return 60;
      if (highest <= 100) return 120;
      if (highest <= 200) return 240;
      return ((highest / 50).ceil() * 50).toDouble();
    }

    return (highest + 1).ceilToDouble();
  }

  double _getYAxisInterval(double maxY) {
    if (_selectedMetric == 'count') return 1;
    if (_selectedMetric == 'intensity') return 1;

    if (_selectedMetric == 'reps') {
      if (maxY <= 25) return 5;
      if (maxY <= 60) return 10;
      if (maxY <= 120) return 20;
      return 25;
    }

    if (_selectedMetric == 'weight') {
      if (maxY <= 60) return 10;
      if (maxY <= 120) return 20;
      return 25;
    }

    return 1;
  }

  List<FlSpot> _toSpots(Map<String, double> trend) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final spots = <FlSpot>[];

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final value = trend[key] ?? 0.0;
      spots.add(FlSpot((_selectedDays - 1 - i).toDouble(), value));
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
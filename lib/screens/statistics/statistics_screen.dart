import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workout_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String _dayLabel(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.';
  }

  String _formatNumber(dynamic value) {
    final number = (value as num).toDouble();
    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    }
    return number.toStringAsFixed(1);
  }

  double _gridInterval(double maxVolume) {
    if (maxVolume <= 100) return 20;
    if (maxVolume <= 500) return 100;
    if (maxVolume <= 1000) return 200;
    return (maxVolume / 5).ceilToDouble();
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final dailyStats = provider.dailyStats;

    final maxVolume = dailyStats.isEmpty
        ? 0.0
        : dailyStats
              .map((week) => (week['volume'] as num).toDouble())
              .fold<double>(
                0,
                (max, value) => value > max ? value : max,
              );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          actions: [
            IconButton(
              tooltip: 'Refresh statistics',
              onPressed: provider.loadStats,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: provider.loadStats,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;

                  final cards = [
                    _StatCard(
                      icon: Icons.fitness_center,
                      value: '${provider.currentDayWorkouts}',
                      label: 'Workouts today',
                    ),
                    _StatCard(
                      icon: Icons.repeat,
                      value: '${provider.currentDaySets}',
                      label: 'Sets today',
                    ),
                    _StatCard(
                      icon: Icons.local_fire_department,
                      value:
                          '${provider.currentDayVolume.toStringAsFixed(0)} kg',
                      label: 'Volume today',
                    ),
                    _StatCard(
                      icon: Icons.speed,
                      value:
                          '${provider.averageVolumePerWorkout.toStringAsFixed(0)} kg',
                      label: 'Average per workout',
                    ),
                  ];

                  if (wide) {
                    return Row(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          Expanded(child: cards[i]),
                          if (i < cards.length - 1)
                            const SizedBox(width: 12),
                        ],
                      ],
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i < cards.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Daily Volume',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Total weight × reps logged each day',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                  child: SizedBox(
                    height: 300,
                    child: dailyStats.isEmpty
                        ? const Center(
                            child: Text('No workout data yet.'),
                          )
                        : BarChart(
                            BarChartData(
                              minY: 0,
                              maxY: maxVolume <= 0 ? 100 : maxVolume * 1.25,
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval:
                                    _gridInterval(maxVolume),
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final volume =
                                        dailyStats[groupIndex]['volume']
                                            as num;

                                    return BarTooltipItem(
                                      '${volume.toStringAsFixed(0)} kg',
                                      const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 48,
                                    interval: _gridInterval(maxVolume),
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        _formatAxisValue(value),
                                        style:
                                            const TextStyle(fontSize: 11),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();

                                      if (index < 0 ||
                                          index >= dailyStats.length) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _dayLabel(
                                            dailyStats[index]['date']
                                                as String,
                                          ),
                                          style:
                                              const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0;
                                    i < dailyStats.length;
                                    i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY:
                                            (dailyStats[i]['volume'] as num)
                                                .toDouble(),
                                        width: 28,
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                    ],
                                  ),
                            ],
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;

                  final allTime = Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.bar_chart,
                        color: Colors.green,
                      ),
                      title: const Text(
                        'All-time volume',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${provider.volume.toStringAsFixed(0)} kg total',
                      ),
                    ),
                  );

                  final pr = Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.emoji_events,
                        color: Colors.green,
                      ),
                      title: const Text(
                        'Personal Record',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: provider.personalRecord == null
                          ? const Text('No logged sets yet.')
                          : Text(
                              '${provider.personalRecord!['name']} — '
                              '${_formatNumber(provider.personalRecord!['weight'])} kg × '
                              '${provider.personalRecord!['reps']} reps',
                            ),
                    ),
                  );

                  if (wide) {
                    return Row(
                      children: [
                        Expanded(child: allTime),
                        const SizedBox(width: 12),
                        Expanded(child: pr),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      allTime,
                      const SizedBox(height: 12),
                      pr,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

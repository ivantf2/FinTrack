import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workout_provider.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _volume(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final pr = provider.personalRecord;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Ready for your next workout?',
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center,
                    value: '${provider.workoutCount}',
                    label: 'Workouts',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: _volume(provider.volume),
                    label: 'Volume (kg)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.repeat,
                    value: '${provider.setCount}',
                    label: 'Total Sets',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.emoji_events,
                    value: pr == null ? '-' : '${pr['weight']} kg',
                    label: 'Best Lift',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Latest Personal Record',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        pr == null
                            ? 'Complete a workout to set your first PR.'
                            : '${pr['name']}: ${pr['weight']} kg × ${pr['reps']} reps',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.workouts.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: const Text(
                    'Latest workout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(provider.workouts.first.name),
                  trailing: Text(
                    '${provider.workouts.first.exerciseCount} exercises',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

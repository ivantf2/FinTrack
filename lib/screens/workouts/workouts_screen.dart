import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/workout_card.dart';
import 'create_workout_screen.dart';
import 'workout_details_screen.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  Future<void> _create(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
    );
  }

  Future<void> _delete(BuildContext context, dynamic workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text('Delete "${workout.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final exercises = context.read<ExerciseProvider>().exercises;
    await context.read<WorkoutProvider>().deleteWorkout(workout, exercises);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),
          actions: [
            IconButton(
              tooltip: 'History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
            ),
            IconButton(
              tooltip: 'Create workout',
              onPressed: () => _create(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.workouts.isEmpty
                ? const Center(
                    child: Text(
                      'No workouts yet. Create your first workout!',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = provider.workouts[index];

                      return WorkoutCard(
                        workout: workout,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutDetailsScreen(workout: workout),
                            ),
                          );
                        },
                        onDelete: () => _delete(context, workout),
                      );
                    },
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/workout.dart';
import 'active_workout_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${workout.exerciseCount} exercises',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 18),
          ...workout.exercises.map(
            (exercise) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.green),
                title: Text(exercise.name),
                subtitle: Text(exercise.muscleGroup),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(workout: workout),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

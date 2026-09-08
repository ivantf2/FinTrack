import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _nameController = TextEditingController();
  final Set<int> _selected = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final exercises = context
        .read<ExerciseProvider>()
        .exercises
        .where((e) => _selected.contains(e.id))
        .toList();

    if (name.isEmpty) {
      _show('Enter a workout name.');
      return;
    }
    if (exercises.isEmpty) {
      _show('Select at least one exercise.');
      return;
    }

    await context.read<WorkoutProvider>().createWorkout(
      name: name,
      exercises: exercises,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.watch<ExerciseProvider>().exercises;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Workout Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g. Push Day',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Select Exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...exercises.map(
            (exercise) => Card(
              child: CheckboxListTile(
                value: _selected.contains(exercise.id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selected.add(exercise.id);
                    } else {
                      _selected.remove(exercise.id);
                    }
                  });
                },
                title: Text(exercise.name),
                subtitle: Text(exercise.muscleGroup),
                secondary: const Icon(
                  Icons.fitness_center,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Create Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

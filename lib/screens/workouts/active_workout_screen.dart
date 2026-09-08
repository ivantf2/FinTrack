import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../models/workout_set.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Map<int, List<WorkoutSet>> _sets = {};
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.workout.exercises) {
      _sets[exercise.id] = [WorkoutSet(setNumber: 1)];
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _elapsed {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _addSet(int exerciseId) {
    setState(() {
      final sets = _sets[exerciseId]!;
      sets.add(WorkoutSet(setNumber: sets.length + 1));
    });
  }

  Future<void> _finish() async {
    final provider = context.read<WorkoutProvider>();
    final exercises = context.read<ExerciseProvider>().exercises;

    await provider.finishWorkout(
      workout: widget.workout,
      sets: _sets,
      exercises: exercises,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout completed and saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _elapsed,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...widget.workout.exercises.map(
            (exercise) => _ExerciseWorkoutCard(
              exerciseName: exercise.name,
              sets: _sets[exercise.id]!,
              onAddSet: () => _addSet(exercise.id),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _finish,
              child: const Text('Finish Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseWorkoutCard extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutSet> sets;
  final VoidCallback onAddSet;

  const _ExerciseWorkoutCard({
    required this.exerciseName,
    required this.sets,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exerciseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text('Set', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: Text('Weight', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: Text('Reps', style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(width: 42),
              ],
            ),
            const SizedBox(height: 8),
            ...sets.map((set) => _SetRow(workoutSet: set)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutSet workoutSet;

  const _SetRow({required this.workoutSet});

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController();
    _reps = TextEditingController();
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '${widget.workoutSet.setNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'kg',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                widget.workoutSet.weight = double.tryParse(value) ?? 0;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'reps',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                widget.workoutSet.reps = int.tryParse(value) ?? 0;
              },
            ),
          ),
          SizedBox(
            width: 42,
            child: Checkbox(
              value: widget.workoutSet.completed,
              onChanged: (value) {
                setState(() {
                  widget.workoutSet.completed = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  String _date(DateTime? value) {
    if (value == null) return 'Unknown date';
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: workouts.isEmpty
          ? const Center(child: Text('No workout history yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.history, color: Colors.green),
                    title: Text(
                      workout.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_date(workout.date)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutHistoryDetailsScreen(
                            workoutId: workout.id,
                            workoutName: workout.name,
                            workoutDate: workout.date,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class WorkoutHistoryDetailsScreen extends StatefulWidget {
  final int workoutId;
  final String workoutName;
  final DateTime? workoutDate;

  const WorkoutHistoryDetailsScreen({
    super.key,
    required this.workoutId,
    required this.workoutName,
    required this.workoutDate,
  });

  @override
  State<WorkoutHistoryDetailsScreen> createState() =>
      _WorkoutHistoryDetailsScreenState();
}

class _WorkoutHistoryDetailsScreenState
    extends State<WorkoutHistoryDetailsScreen> {
  List<Map<String, dynamic>> _sets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sets =
        await context.read<WorkoutProvider>().getSets(widget.workoutId);

    if (!mounted) return;

    setState(() {
      _sets = sets;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.read<ExerciseProvider>().exercises;
    final grouped = <int, List<Map<String, dynamic>>>{};

    for (final set in _sets) {
      final id = set['exercise_id'] as int;
      grouped.putIfAbsent(id, () => []).add(set);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.workoutName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sets.isEmpty
              ? const Center(child: Text('No saved sets for this workout.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (widget.workoutDate != null)
                      Text(
                        '${widget.workoutDate!.day.toString().padLeft(2, '0')}.'
                        '${widget.workoutDate!.month.toString().padLeft(2, '0')}.'
                        '${widget.workoutDate!.year}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    const SizedBox(height: 18),
                    ...grouped.entries.map((entry) {
                      final exercise = _findExercise(exercises, entry.key);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise?.name ?? 'Unknown Exercise',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...entry.value.map(
                                (set) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: Text('Set ${set['set_number']}'),
                                      ),
                                      Expanded(
                                        child: Text('${set['weight']} kg'),
                                      ),
                                      Expanded(
                                        child: Text('${set['reps']} reps'),
                                      ),
                                      Icon(
                                        set['completed'] == 1
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: set['completed'] == 1
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Exercise? _findExercise(List<Exercise> exercises, int id) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }
}

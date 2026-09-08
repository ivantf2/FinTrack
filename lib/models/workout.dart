import 'exercise.dart';

class Workout {
  final int id;
  final String name;
  final List<Exercise> exercises;
  final DateTime? date;

  const Workout({
    required this.id,
    required this.name,
    required this.exercises,
    this.date,
  });

  int get exerciseCount => exercises.length;
}

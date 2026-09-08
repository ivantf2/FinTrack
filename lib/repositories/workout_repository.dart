import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../services/database_service.dart';

class WorkoutRepository {
  Future<List<Workout>> getWorkouts(List<Exercise> exercises) async {
    final rows = await DatabaseService.getWorkouts();
    final result = <Workout>[];

    for (final row in rows) {
      final id = row['id'] as int;
      final ids = await DatabaseService.getWorkoutExerciseIds(id);

      result.add(
        Workout(
          id: id,
          name: row['name'] as String,
          exercises: exercises
              .where((exercise) => ids.contains(exercise.id))
              .toList(),
          date: row['date'] != null
              ? DateTime.tryParse(row['date'] as String)
              : null,
        ),
      );
    }

    return result;
  }

  Future<void> createWorkout({
    required String name,
    required List<Exercise> exercises,
  }) {
    return DatabaseService.insertWorkout(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      exerciseIds: exercises.map((e) => e.id).toList(),
      date: DateTime.now(),
    );
  }

  Future<void> saveSets({
    required Workout workout,
    required Map<int, List<WorkoutSet>> sets,
  }) async {
    for (final exercise in workout.exercises) {
      await DatabaseService.saveWorkoutSets(
        workoutId: workout.id,
        exerciseId: exercise.id,
        sets: sets[exercise.id] ?? [],
      );
    }
  }

  Future<void> deleteWorkout(int id) =>
      DatabaseService.deleteWorkout(id);

  Future<List<Map<String, dynamic>>> getSets(int workoutId) =>
      DatabaseService.getWorkoutSets(workoutId);
}

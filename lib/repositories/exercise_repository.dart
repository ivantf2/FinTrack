import '../models/exercise.dart';
import '../services/database_service.dart';
import '../services/exercise_api_service.dart';

class ExerciseRepository {
  static const seedExercises = <Exercise>[
    Exercise(id: 1, name: 'Bench Press', muscleGroup: 'Chest',
        description: 'Barbell pressing exercise for the chest.'),
    Exercise(id: 2, name: 'Incline Dumbbell Press', muscleGroup: 'Chest',
        description: 'Dumbbell pressing exercise targeting the upper chest.'),
    Exercise(id: 3, name: 'Pull Up', muscleGroup: 'Back',
        description: 'Bodyweight exercise targeting the back and biceps.'),
    Exercise(id: 4, name: 'Barbell Row', muscleGroup: 'Back',
        description: 'Compound pulling exercise for the back.'),
    Exercise(id: 5, name: 'Squat', muscleGroup: 'Legs',
        description: 'Compound lower-body exercise targeting the legs.'),
    Exercise(id: 6, name: 'Leg Press', muscleGroup: 'Legs',
        description: 'Machine exercise targeting the quadriceps and glutes.'),
    Exercise(id: 7, name: 'Shoulder Press', muscleGroup: 'Shoulders',
        description: 'Pressing exercise targeting the shoulders.'),
    Exercise(id: 8, name: 'Triceps Pushdown', muscleGroup: 'Arms',
        description: 'Cable exercise targeting the triceps.'),
    Exercise(id: 9, name: 'Dumbbell Curl', muscleGroup: 'Arms',
        description: 'Dumbbell exercise targeting the biceps.'),
    Exercise(id: 10, name: 'Romanian Deadlift', muscleGroup: 'Legs',
        description: 'Hip-hinge movement targeting the hamstrings and glutes.'),
    Exercise(id: 11, name: 'Lat Pulldown', muscleGroup: 'Back',
        description: 'Cable pulling exercise targeting the lats.'),
    Exercise(id: 12, name: 'Lateral Raise', muscleGroup: 'Shoulders',
        description: 'Isolation exercise targeting the lateral deltoids.'),
  ];

  Future<List<Exercise>> getExercises() async {
    await DatabaseService.seedExercises(seedExercises);
    return DatabaseService.getExercises();
  }

  Future<List<Exercise>> refreshFromApi() async {
    final exercises = await ExerciseApiService.fetchExercises();
    await DatabaseService.upsertExercises(exercises);
    return DatabaseService.getExercises();
  }
}

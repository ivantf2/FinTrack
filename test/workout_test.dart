import 'package:flutter_test/flutter_test.dart';

import 'package:fittrack/models/exercise.dart';
import 'package:fittrack/models/workout.dart';

void main() {
  test('Workout reports the number of selected exercises', () {
    const workout = Workout(
      id: 1,
      name: 'Push Day',
      exercises: [
        Exercise(
          id: 1,
          name: 'Bench Press',
          muscleGroup: 'Chest',
          description: 'Chest exercise',
        ),
        Exercise(
          id: 2,
          name: 'Shoulder Press',
          muscleGroup: 'Shoulders',
          description: 'Shoulder exercise',
        ),
      ],
    );

    expect(workout.exerciseCount, 2);
  });
}

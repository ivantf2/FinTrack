import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../repositories/workout_repository.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository repository;

  WorkoutProvider(this.repository);

  List<Workout> _workouts = [];
  bool _loading = false;
  int _workoutCount = 0;
  int _setCount = 0;
  double _volume = 0;
  Map<String, dynamic>? _personalRecord;
  List<Map<String, dynamic>> _dailyStats = [];

  List<Workout> get workouts => List.unmodifiable(_workouts);
  bool get loading => _loading;
  int get workoutCount => _workoutCount;
  int get setCount => _setCount;
  double get volume => _volume;
  Map<String, dynamic>? get personalRecord => _personalRecord;
  List<Map<String, dynamic>> get dailyStats =>
      List.unmodifiable(_dailyStats);

  Map<String, dynamic>? get currentDayStats =>
      _dailyStats.isEmpty ? null : _dailyStats.last;

  double get currentDayVolume =>
      (currentDayStats?['volume'] as num?)?.toDouble() ?? 0;

  int get currentDayWorkouts =>
      (currentDayStats?['workouts'] as int?) ?? 0;

  int get currentDaySets =>
      (currentDayStats?['sets'] as int?) ?? 0;

  double get averageVolumePerWorkout {
    if (currentDayWorkouts == 0) return 0;
    return currentDayVolume / currentDayWorkouts;
  }

  Future<void> load(List<Exercise> exercises) async {
    _loading = true;
    notifyListeners();

    _workouts = await repository.getWorkouts(exercises);
    await loadStats();

    _loading = false;
    notifyListeners();
  }

  Future<void> loadStats() async {
    final results = await Future.wait([
      DatabaseService.getWorkoutCount(),
      DatabaseService.getSetCount(),
      DatabaseService.getTotalVolume(),
      DatabaseService.getPersonalRecord(),
      DatabaseService.getDailyStats(days: 7),
    ]);

    _workoutCount = results[0] as int;
    _setCount = results[1] as int;
    _volume = results[2] as double;
    _personalRecord = results[3] as Map<String, dynamic>?;
    _dailyStats = results[4] as List<Map<String, dynamic>>;

    notifyListeners();
  }

  Future<void> createWorkout({
    required String name,
    required List<Exercise> exercises,
  }) async {
    await repository.createWorkout(name: name, exercises: exercises);
    await load(exercises);
  }

  Future<void> deleteWorkout(
    Workout workout,
    List<Exercise> exercises,
  ) async {
    await repository.deleteWorkout(workout.id);
    await load(exercises);
  }

  Future<void> finishWorkout({
    required Workout workout,
    required Map<int, List<WorkoutSet>> sets,
    required List<Exercise> exercises,
  }) async {
    await repository.saveSets(workout: workout, sets: sets);
    await load(exercises);
  }

  Future<List<Map<String, dynamic>>> getSets(int workoutId) =>
      repository.getSets(workoutId);
}

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository repository;

  ExerciseProvider(this.repository);

  List<Exercise> _exercises = [];
  bool _loading = false;
  String? _error;

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _exercises = await repository.getExercises();
      _error = null;
    } catch (_) {
      _error = 'Could not load local exercises.';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> refreshFromApi() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _exercises = await repository.refreshFromApi();
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not reach the exercise API.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}

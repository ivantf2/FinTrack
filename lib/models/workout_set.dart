class WorkoutSet {
  final int setNumber;
  double weight;
  int reps;
  bool completed;

  WorkoutSet({
    required this.setNumber,
    this.weight = 0,
    this.reps = 0,
    this.completed = false,
  });
}

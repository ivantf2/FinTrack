class Exercise {
  final int id;
  final String name;
  final String muscleGroup;
  final String description;
  final String? gifUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    this.gifUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscle_group': muscleGroup,
        'description': description,
        'gif_url': gifUrl,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int,
        name: map['name'] as String,
        muscleGroup: map['muscle_group'] as String,
        description: map['description'] as String,
        gifUrl: map['gif_url'] as String?,
      );
}

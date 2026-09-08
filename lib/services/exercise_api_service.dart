import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exercise.dart';

class ExerciseApiService {
  static const _baseUrl =
      'https://oss.exercisedb.dev/api/v1/exercises';

  static int _stableId(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = 31 * hash + codeUnit;
    }
    return -hash.abs();
  }

  static Future<List<Exercise>> fetchExercises({int limit = 30}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?limit=$limit'),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Exercise API returned ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> items;
    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      items = decoded['data'] as List<dynamic>;
    } else {
      throw Exception('Unexpected Exercise API response.');
    }

    return items.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final name = (map['name'] ?? 'Unknown exercise').toString();
      final bodyParts = map['bodyParts'];
      final targets = map['targetMuscles'];

      final muscleGroup = bodyParts is List && bodyParts.isNotEmpty
          ? bodyParts.first.toString()
          : targets is List && targets.isNotEmpty
              ? targets.first.toString()
              : 'Other';

      return Exercise(
        id: _stableId(map['exerciseId']?.toString() ?? name),
        name: name,
        muscleGroup: muscleGroup,
        description: map['overview']?.toString() ??
            'Exercise from the ExerciseDB catalog.',
        gifUrl: map['gifUrl']?.toString(),
      );
    }).toList();
  }
}

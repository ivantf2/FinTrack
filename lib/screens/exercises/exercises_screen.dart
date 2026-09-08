import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_card.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshApi() async {
    final ok = await context.read<ExerciseProvider>().refreshFromApi();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Exercise catalog updated from API.'
              : 'Could not reach the exercise API. Local data is still available.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final filtered = provider.exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(_query) ||
          exercise.muscleGroup.toLowerCase().contains(_query);
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercises'),
          actions: [
            IconButton(
              tooltip: 'Refresh from API',
              onPressed: provider.loading ? null : _refreshApi,
              icon: const Icon(Icons.cloud_download_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (provider.loading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) =>
                    ExerciseCard(exercise: filtered[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/exercise_provider.dart';
import 'providers/workout_provider.dart';
import 'repositories/exercise_repository.dart';
import 'repositories/workout_repository.dart';
import 'screens/exercises/exercises_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/workouts/workouts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(ExerciseRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(WorkoutRepository()),
        ),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  bool _loadedWorkouts = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutsScreen(),
    ExercisesScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkoutsWhenReady();
    });
  }

  void _loadWorkoutsWhenReady() {
    if (!mounted || _loadedWorkouts) return;

    final exerciseProvider = context.read<ExerciseProvider>();

    if (exerciseProvider.exercises.isNotEmpty) {
      _loadedWorkouts = true;

      context.read<WorkoutProvider>().load(
        exerciseProvider.exercises,
      );
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _loadWorkoutsWhenReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_gymnastics_outlined),
            selectedIcon: Icon(Icons.sports_gymnastics),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
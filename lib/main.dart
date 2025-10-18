import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/exercise.dart';
import 'models/workout.dart';
import 'data/workout_repo.dart';
import 'providers/workout_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'screens/create_workout_screen.dart';
import 'screens/add_exercise_screen.dart';
import 'screens/previous_workouts_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  final repo = WorkoutRepo();
  final workoutProvider = WorkoutProvider(repo);
  await workoutProvider.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => workoutProvider,
      child: const FitFlowApp(),
    ),
  );
}

class FitFlowApp extends StatelessWidget {
  const FitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitFlow',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E6CF6), // Vibrant blue
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF3E6CF6), // Vibrant blue
          secondary: const Color(0xFF20C38B), // Fresh green
          tertiary: const Color(0xFFFFA733), // Energy orange
          surface: const Color(0xFFF8FAFF), // Soft gradient base
          surfaceContainerHighest: const Color(0xFFE8F0FF), // Gradient end
          onSurface: const Color(0xFF0E1625), // Primary text
          onSurfaceVariant: const Color(0xFF7C8AA3), // Subtext
          outline: const Color(0xFFE0E0E0),
          outlineVariant: const Color(0xFFF0F0F0),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 8,
          height: 80,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF64B5F6),
          secondary: const Color(0xFF81C784),
          tertiary: const Color(0xFFFFB74D),
          surface: const Color(0xFF121212),
          surfaceContainerHighest: const Color(0xFF1E1E1E),
          outline: const Color(0xFF404040),
          outlineVariant: const Color(0xFF2A2A2A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 8,
          height: 80,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
              routes: {
                '/': (_) => const MainNavigationScreen(),
                WorkoutDetailScreen.route: (_) => const WorkoutDetailScreen(),
                CreateWorkoutScreen.route: (_) => const CreateWorkoutScreen(),
                AddExerciseScreen.route: (_) => const AddExerciseScreen(),
                PreviousWorkoutsScreen.route: (_) => const PreviousWorkoutsScreen(),
                SettingsScreen.route: (_) => const SettingsScreen(),
              },
    );
  }
}

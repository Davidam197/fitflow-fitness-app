import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/exercise.dart';
import 'models/workout.dart';
import 'data/workout_repo.dart';
import 'providers/workout_provider.dart';
import 'providers/membership_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'screens/create_workout_screen.dart';
import 'screens/add_exercise_screen.dart';
import 'screens/previous_workouts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/import_workout_screen.dart';
import 'screens/sub_workout_screen.dart';
import 'screens/imported_workout_detail_screen.dart';
import 'theme/energetic_fitness_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  final repo = WorkoutRepo();
  final workoutProvider = WorkoutProvider(repo);
  await workoutProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => workoutProvider),
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
      ],
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
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: energeticFitnessLight,
      darkTheme: energeticFitnessDark,
              routes: {
                '/': (_) => const MainNavigationScreen(),
                WorkoutDetailScreen.route: (_) => const WorkoutDetailScreen(),
                CreateWorkoutScreen.route: (_) => const CreateWorkoutScreen(),
                AddExerciseScreen.route: (_) => const AddExerciseScreen(),
                PreviousWorkoutsScreen.route: (_) => const PreviousWorkoutsScreen(),
                SettingsScreen.route: (_) => const SettingsScreen(),
                ImportWorkoutScreen.route: (_) => const ImportWorkoutScreen(),
                SubWorkoutScreen.route: (_) => const SubWorkoutScreen(
                  mainWorkoutId: '',
                  subWorkoutName: '',
                  exercises: [],
                ),
                ImportedWorkoutDetailScreen.route: (_) => const ImportedWorkoutDetailScreen(
                  workoutId: '',
                ),
              },
    );
  }
}

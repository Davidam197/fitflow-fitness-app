import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../utils/responsive.dart';
import 'sub_workout_screen.dart';

class ImportedWorkoutDetailScreen extends StatelessWidget {
  static const route = '/imported-workout-detail';
  final String workoutId;

  const ImportedWorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final workout = prov.byId(workoutId);

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context, prov, workoutId, workout.name),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Workout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8FAFF), // Soft gradient base
              const Color(0xFFE8F0FF), // Gradient end
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: Responsive.getScreenPadding(context),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3E6CF6).withOpacity(0.1),
                    const Color(0xFF7A5CFF).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3E6CF6).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      fontSize: Responsive.getTitleFontSize(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E1625),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: TextStyle(
                      fontSize: Responsive.getBodyFontSize(context),
                      color: const Color(0xFF7C8AA3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E6CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${workout.exercises.length} workout groups',
                          style: const TextStyle(
                            color: Color(0xFF3E6CF6),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E6CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${workout.durationMinutes} min total',
                          style: const TextStyle(
                            color: Color(0xFF3E6CF6),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sub-workout cards
            Text(
              'Workout Groups',
              style: TextStyle(
                fontSize: Responsive.getSubtitleFontSize(context),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0E1625),
              ),
            ),
            const SizedBox(height: 16),

            ...workout.exercises.map((exercise) => _SubWorkoutCard(
              exercise: exercise,
              onStartWorkout: () => _startSubWorkout(context, workoutId, exercise),
            )),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startSubWorkout(BuildContext context, String mainWorkoutId, Exercise subWorkout) {
    // Get the actual exercises from the main workout
    final prov = context.read<WorkoutProvider>();
    final mainWorkout = prov.byId(mainWorkoutId);
    
    // Find the corresponding workout section based on the sub-workout name
    final sectionName = subWorkout.name.replaceAll(' Workout', '').toLowerCase();
    
    // Get the actual exercises from the scraped data
    final exercises = _getActualExercisesForSection(context, mainWorkout, sectionName);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubWorkoutScreen(
          mainWorkoutId: mainWorkoutId,
          subWorkoutName: subWorkout.name,
          exercises: exercises,
        ),
      ),
    );
  }

  List<Exercise> _getActualExercisesForSection(BuildContext context, Workout mainWorkout, String sectionName) {
    // The web scraping service now creates individual workouts for each section
    // We need to find the matching workout from the provider
    final prov = context.read<WorkoutProvider>();
    final allWorkouts = prov.workouts;
    
    // Find the workout that matches this section
    final matchingWorkout = allWorkouts.firstWhere(
      (workout) => workout.name.toLowerCase().contains(sectionName) && 
                   workout.description.contains('Imported from web'),
      orElse: () => mainWorkout,
    );
    
    return matchingWorkout.exercises;
  }


  void _showDeleteDialog(BuildContext context, WorkoutProvider prov, String workoutId, String workoutName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "$workoutName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await prov.deleteWorkout(workoutId);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to workouts
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "$workoutName"')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SubWorkoutCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onStartWorkout;

  const _SubWorkoutCard({
    required this.exercise,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3E6CF6).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3E6CF6),
                      const Color(0xFF7A5CFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: Responsive.getSubtitleFontSize(context),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0E1625),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.notes,
                      style: TextStyle(
                        fontSize: Responsive.getBodyFontSize(context),
                        color: const Color(0xFF7C8AA3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.timer,
                label: '${exercise.durationSeconds ~/ 60} min',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.fitness_center,
                label: exercise.notes,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartWorkout,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3E6CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3E6CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3E6CF6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E6CF6),
            ),
          ),
        ],
      ),
    );
  }
}

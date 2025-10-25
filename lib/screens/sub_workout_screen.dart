import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../utils/responsive.dart';

class SubWorkoutScreen extends StatelessWidget {
  static const route = '/sub-workout';
  final String mainWorkoutId;
  final String subWorkoutName;
  final List<Exercise> exercises;

  const SubWorkoutScreen({
    super.key,
    required this.mainWorkoutId,
    required this.subWorkoutName,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final mainWorkout = prov.byId(mainWorkoutId);

    return Scaffold(
      appBar: AppBar(
        title: Text(subWorkoutName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context, prov, mainWorkoutId, mainWorkout.name),
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
                    subWorkoutName,
                    style: TextStyle(
                      fontSize: Responsive.getTitleFontSize(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E1625),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E6CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${exercises.length} exercises',
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
                          '${exercises.fold(0, (sum, ex) => sum + ex.sets)} total sets',
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

            // Exercises
            Text(
              'Exercises',
              style: TextStyle(
                fontSize: Responsive.getSubtitleFontSize(context),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0E1625),
              ),
            ),
            const SizedBox(height: 16),

            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _ExerciseCard(
                exercise: exercise,
                exerciseNumber: index + 1,
                onComplete: () => _markExerciseComplete(context, prov, mainWorkoutId, index),
              );
            }),

            const SizedBox(height: 24),

            // Start/Complete Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _startSubWorkout(context, prov, mainWorkoutId, subWorkoutName),
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _markExerciseComplete(BuildContext context, WorkoutProvider prov, String workoutId, int exerciseIndex) {
    // Mark exercise as complete
    final exercise = exercises[exerciseIndex];
    prov.incrementSet(workoutId, exercise.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${exercise.name} completed!')),
    );
  }

  void _startSubWorkout(BuildContext context, WorkoutProvider prov, String workoutId, String subWorkoutName) {
    // Start the sub-workout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting $subWorkoutName...')),
    );
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
                Navigator.pop(context); // Go back to home
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

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int exerciseNumber;
  final VoidCallback onComplete;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseNumber,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3E6CF6).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6CF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$exerciseNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: Responsive.getBodyFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0E1625),
                  ),
                ),
              ),
              IconButton(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline, color: Color(0xFF3E6CF6)),
                tooltip: 'Mark Complete',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.repeat,
                label: '${exercise.sets} sets',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.fitness_center,
                label: '${exercise.reps} reps',
              ),
              if (exercise.durationSeconds > 0) ...[
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer,
                  label: '${exercise.durationSeconds}s',
                ),
              ],
            ],
          ),
          if (exercise.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              exercise.notes,
              style: TextStyle(
                fontSize: Responsive.getCaptionFontSize(context),
                color: const Color(0xFF7C8AA3),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3E6CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3E6CF6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3E6CF6),
            ),
          ),
        ],
      ),
    );
  }
}

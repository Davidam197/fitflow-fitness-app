import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
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
    // Parse the stored exercises from the description field
    final exercises = _parseStoredExercises(subWorkout.description);
    
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

  List<Exercise> _parseStoredExercises(String description) {
    // Parse the stored exercises from the description field
    // This is a simplified implementation - in production you'd use proper JSON parsing
    if (description.isEmpty || !description.contains('{')) {
      // Return mock exercises based on workout name for now
      return _getMockExercisesForWorkout(description);
    }
    
    // TODO: Implement proper JSON parsing
    return _getMockExercisesForWorkout(description);
  }

  List<Exercise> _getMockExercisesForWorkout(String workoutName) {
    final name = workoutName.toLowerCase();
    
    if (name.contains('back')) {
      return [
        Exercise(
          id: '1',
          name: 'Pull-ups',
          sets: 5,
          reps: 20,
          durationSeconds: 60,
          equipment: 'Pull-up bar',
          notes: 'Rep scheme: 20, 15, 12, 10, 10',
          description: 'Hang from bar, pull body up until chin clears bar',
        ),
        Exercise(
          id: '2',
          name: 'Push-ups',
          sets: 5,
          reps: 20,
          durationSeconds: 60,
          equipment: 'None',
          notes: 'Keep body straight',
          description: 'Start in plank position, lower chest to ground',
        ),
        Exercise(
          id: '3',
          name: 'Hammer Strength Two-Arm Row',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Adjustable Cable Machine',
          notes: 'Squeeze shoulder blades',
          description: 'Pull handles to chest, squeeze shoulder blades together',
        ),
        Exercise(
          id: '4',
          name: 'Dumbbell Row',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Brace yourself on a flat bench with your left knee and hand on the bench and a heavy dumbbell in your right hand. Pull the weight up to your chest; use only your lats and arms; don\'t twist. Repeat for equal reps on each side.',
          description: 'Bend over, pull dumbbells to chest',
        ),
        Exercise(
          id: '5',
          name: 'Swiss Ball Hyperextension',
          sets: 4,
          reps: 25,
          durationSeconds: 60,
          equipment: 'Swiss Ball',
          notes: 'Rep scheme: 25, 20, 15, 15',
          description: 'Lie face down on Swiss ball, lift chest up',
        ),
      ];
    } else if (name.contains('chest')) {
      return [
        Exercise(
          id: '1',
          name: 'Barbell Bench Press',
          sets: 8,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Rep scheme: 12, 10, 10, 8, 8, 6, 4, 4',
          description: 'Lie on bench, lower bar to chest, press up',
        ),
        Exercise(
          id: '2',
          name: 'Incline Dumbbell Bench Press',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Incline bench at 30-45 degrees',
          description: 'Press dumbbells up from chest',
        ),
        Exercise(
          id: '3',
          name: 'Hammer Strength Chest Press',
          sets: 4,
          reps: 15,
          durationSeconds: 60,
          equipment: 'Machine',
          notes: 'Use machine for controlled movement',
          description: 'Press handles together in front of chest',
        ),
        Exercise(
          id: '4',
          name: 'Weighted Dip',
          sets: 4,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Dip bars',
          notes: 'Add weight if possible',
          description: 'Lower body between bars, press up',
        ),
        Exercise(
          id: '5',
          name: 'Cable Flye',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Cable machine',
          notes: 'Keep slight bend in elbows',
          description: 'Bring cables together in front of chest',
        ),
        Exercise(
          id: '6',
          name: 'Push-ups',
          sets: 3,
          reps: 20,
          durationSeconds: 60,
          equipment: 'None',
          notes: 'To failure on last set',
          description: 'Standard push-up movement',
        ),
      ];
    } else if (name.contains('leg')) {
      return [
        Exercise(
          id: '1',
          name: 'Back Squat',
          sets: 7,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Rep scheme: 10, 8, 6, 5, 4, 3, 3',
          description: 'Squat down until thighs parallel to floor',
        ),
        Exercise(
          id: '2',
          name: 'Leg Press',
          sets: 1,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Leg press machine',
          notes: 'To failure / strip set',
          description: 'Press weight with legs, full range of motion',
        ),
        Exercise(
          id: '3',
          name: 'Bodyweight Walking Lunge',
          sets: 4,
          reps: 20,
          durationSeconds: 60,
          equipment: 'None',
          notes: 'Alternating legs',
          description: 'Step forward into lunge, alternate legs',
        ),
        Exercise(
          id: '4',
          name: 'Romanian Deadlift',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Keep back straight',
          description: 'Hinge at hips, lower bar along legs',
        ),
        Exercise(
          id: '5',
          name: 'Seated Leg Curl',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Machine',
          notes: 'Squeeze hamstrings at top',
          description: 'Curl legs up, squeeze hamstrings',
        ),
        Exercise(
          id: '6',
          name: 'Standing Calf Raise',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Machine or bodyweight',
          notes: 'Full range of motion',
          description: 'Rise up on toes, lower slowly',
        ),
      ];
    } else if (name.contains('arm')) {
      return [
        Exercise(
          id: '1',
          name: 'Barbell Biceps Curl',
          sets: 3,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Keep elbows at sides',
          description: 'Curl barbell up, squeeze biceps',
        ),
        Exercise(
          id: '2',
          name: 'Skull Crusher',
          sets: 3,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Lower to forehead, press up',
          description: 'Lower bar to forehead, press up',
        ),
        Exercise(
          id: '3',
          name: 'EZ-Bar Preacher Curl',
          sets: 3,
          reps: 10,
          durationSeconds: 60,
          equipment: 'EZ-Bar',
          notes: 'Use preacher bench',
          description: 'Curl EZ-bar on preacher bench',
        ),
        Exercise(
          id: '4',
          name: 'Dumbbell Lying Triceps Extension',
          sets: 3,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Lie on bench',
          description: 'Lower dumbbells behind head, press up',
        ),
        Exercise(
          id: '5',
          name: 'Dumbbell Hammer Curl',
          sets: 3,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Neutral grip',
          description: 'Curl dumbbells with neutral grip',
        ),
        Exercise(
          id: '6',
          name: 'Rope Pressdown',
          sets: 3,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Cable machine',
          notes: 'Press down and out',
          description: 'Press rope down and out',
        ),
        Exercise(
          id: '7',
          name: 'Barbell Wrist Curl',
          sets: 3,
          reps: 20,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Forearm strength',
          description: 'Curl barbell with wrists',
        ),
        Exercise(
          id: '8',
          name: 'Barbell Reverse Wrist Curl',
          sets: 3,
          reps: 20,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Reverse grip',
          description: 'Curl barbell with reverse grip',
        ),
      ];
    } else if (name.contains('shoulder')) {
      return [
        Exercise(
          id: '1',
          name: 'Military Press',
          sets: 7,
          reps: 10,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Rep scheme: 10, 8, 6, 5, 4, 3, 3',
          description: 'Press barbell overhead from shoulders',
        ),
        Exercise(
          id: '2',
          name: 'Arnold Press',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Rotate as you press',
          description: 'Start with palms facing you, rotate as you press',
        ),
        Exercise(
          id: '3',
          name: 'Barbell Shrug',
          sets: 4,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Barbell',
          notes: 'Squeeze shoulders up',
          description: 'Shrug shoulders up, hold briefly',
        ),
        Exercise(
          id: '4',
          name: 'Dumbbell Lateral Raise',
          sets: 3,
          reps: 15,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Lead with pinkies',
          description: 'Raise dumbbells to sides',
        ),
        Exercise(
          id: '5',
          name: 'Dumbbell Front Raise',
          sets: 3,
          reps: 15,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Alternating arms',
          description: 'Raise dumbbells in front',
        ),
        Exercise(
          id: '6',
          name: 'Dumbbell Rear-Delt Flye',
          sets: 3,
          reps: 15,
          durationSeconds: 60,
          equipment: 'Dumbbells',
          notes: 'Bent over position',
          description: 'Fly dumbbells back, squeeze rear delts',
        ),
      ];
    } else if (name.contains('core')) {
      return [
        Exercise(
          id: '1',
          name: 'Hanging Leg Raise',
          sets: 3,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Pull-up bar',
          notes: 'Control the movement',
          description: 'Hang from bar, raise legs up',
        ),
        Exercise(
          id: '2',
          name: 'Cable Woodchop',
          sets: 3,
          reps: 12,
          durationSeconds: 60,
          equipment: 'Cable machine',
          notes: 'Rotate through core',
          description: 'Pull cable across body',
        ),
        Exercise(
          id: '3',
          name: 'Swiss Ball Crunch',
          sets: 3,
          reps: 15,
          durationSeconds: 60,
          equipment: 'Swiss Ball',
          notes: 'Full range of motion',
          description: 'Crunch on Swiss ball',
        ),
      ];
    }
    
    // Default exercises if no specific workout type
    return [
      Exercise(
        id: '1',
        name: 'General Exercise',
        sets: 3,
        reps: 10,
        durationSeconds: 60,
        equipment: 'Various',
        notes: 'Customize as needed',
        description: 'General exercise movement',
      ),
    ];
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

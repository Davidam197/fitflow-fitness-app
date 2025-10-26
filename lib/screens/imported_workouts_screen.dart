import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/responsive.dart';
import 'import_workout_screen.dart';
import 'imported_workout_detail_screen.dart';

class ImportedWorkoutsScreen extends StatelessWidget {
  const ImportedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF), // Light blue background
              Color(0xFFE8F0FF), // Slightly darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(Responsive.getSpacing(context)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.getSpacing(context)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7A5CFF).withOpacity(0.1),
                            const Color(0xFF3E6CF6).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        border: Border.all(
                          color: const Color(0xFF7A5CFF).withOpacity(0.2),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.getSpacing(context) * 0.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7A5CFF), Color(0xFF3E6CF6)],
                          ),
                          borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 0.5),
                        ),
                        child: Icon(
                          Icons.download,
                          color: Colors.white,
                          size: Responsive.getIconSize(context),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.getSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imported Workouts',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0E1625), // Dark navy
                            ),
                          ),
                          Text(
                            'Manage your imported workout plans',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF7C8AA3), // Subtext
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImportWorkoutScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5CFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, provider, child) {
                    final importedWorkouts = provider.workouts
                        .where((w) => w.description.contains('Imported from web'))
                        .toList();

                    if (importedWorkouts.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(Responsive.getSpacing(context)),
                      itemCount: importedWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = importedWorkouts[index];
                        return _ImportedWorkoutCard(
                          workout: workout,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImportedWorkoutDetailScreen(
                                  workoutId: workout.id,
                                ),
                              ),
                            );
                          },
                          onMoveToHome: () => _moveToHome(context, provider, workout),
                          onMoveToWorkouts: () => _moveToWorkouts(context, provider, workout),
                          onDelete: () => _deleteWorkout(context, provider, workout),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.getSpacing(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.getSpacing(context) * 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A5CFF), Color(0xFF3E6CF6)],
                ),
                borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 2),
              ),
              child: Icon(
                Icons.download_outlined,
                size: Responsive.getIconSize(context) * 2,
                color: Colors.white,
              ),
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            Text(
              'No Imported Workouts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E1625),
              ),
            ),
            SizedBox(height: Responsive.getSpacing(context)),
            Text(
              'Import workout plans from the web to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7C8AA3),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImportWorkoutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Import Workout'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A5CFF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSpacing(context) * 2,
                  vertical: Responsive.getSpacing(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveToHome(BuildContext context, WorkoutProvider provider, workout) {
    // Update workout to remove "Imported from web" from description
    final updatedWorkout = workout.copyWith(
      description: workout.description.replaceAll(' (Imported from web)', ''),
    );
    
    provider.updateWorkout(updatedWorkout);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved "${workout.name}" to Home'),
        backgroundColor: const Color(0xFF7A5CFF),
      ),
    );
  }

  void _moveToWorkouts(BuildContext context, WorkoutProvider provider, workout) {
    // Update workout to remove "Imported from web" from description
    final updatedWorkout = workout.copyWith(
      description: workout.description.replaceAll(' (Imported from web)', ''),
    );
    
    provider.updateWorkout(updatedWorkout);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved "${workout.name}" to Workouts'),
        backgroundColor: const Color(0xFF4E6CF8),
      ),
    );
  }

  void _deleteWorkout(BuildContext context, WorkoutProvider provider, workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "${workout.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await provider.deleteWorkout(workout.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${workout.name}"')),
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

class _ImportedWorkoutCard extends StatelessWidget {
  final dynamic workout;
  final VoidCallback onTap;
  final VoidCallback onMoveToHome;
  final VoidCallback onMoveToWorkouts;
  final VoidCallback onDelete;

  const _ImportedWorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onMoveToHome,
    required this.onMoveToWorkouts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.getSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0E1625),
                          ),
                        ),
                        SizedBox(height: Responsive.getSpacing(context) * 0.5),
                        Text(
                          '${workout.exercises.length} exercises',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7C8AA3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'move_to_home':
                          onMoveToHome();
                          break;
                        case 'move_to_workouts':
                          onMoveToWorkouts();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'move_to_home',
                        child: Row(
                          children: [
                            Icon(Icons.home, size: 20),
                            SizedBox(width: 8),
                            Text('Move to Home'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'move_to_workouts',
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center, size: 20),
                            SizedBox(width: 8),
                            Text('Move to Workouts'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: const Color(0xFF7C8AA3),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Workout'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5CFF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

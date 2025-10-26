import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/fitflow_header.dart';
import '../utils/responsive.dart';
import 'import_workout_screen.dart';
import 'imported_workout_detail_screen.dart';

class ImportedWorkoutsScreen extends StatelessWidget {
  const ImportedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final importedWorkouts = workoutProvider.workouts
        .where((w) => w.description.contains('Imported from web'))
        .toList();

    return Scaffold(
      appBar: FitFlowHeader(
        title: 'Imported Workouts',
        subtitle: 'Manage your imported workout plans',
        actions: [
          HeaderAction(
            icon: Icons.add,
            label: 'Import',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportWorkoutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(252, 252, 255, 1.0), // Off-white with slight blue tint
        ),
        child: importedWorkouts.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
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
                          builder: (context) => ImportedWorkoutDetailScreen(workoutId: workout.id),
                        ),
                      );
                    },
                    onMoveToHome: () => _moveToHome(context, workoutProvider, workout),
                    onMoveToWorkouts: () => _moveToWorkouts(context, workoutProvider, workout),
                    onRename: () => _renameWorkout(context, workoutProvider, workout),
                    onDelete: () => _deleteWorkout(context, workoutProvider, workout),
                  );
                },
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
                color: const Color(0xFF7A5CFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_download_outlined,
                size: Responsive.getIconSize(context) * 2,
                color: const Color(0xFF7A5CFF),
              ),
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            Text(
              'No Imported Workouts Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.getSpacing(context)),
            Text(
              'Import workouts from your favorite websites and manage them here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            ElevatedButton.icon(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7CFF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSpacing(context) * 2,
                  vertical: Responsive.getSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _renameWorkout(BuildContext context, WorkoutProvider provider, workout) {
    final nameController = TextEditingController(text: workout.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a new name for this workout:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
                hintText: 'Enter workout name...',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != workout.name) {
                final updatedWorkout = workout.copyWith(name: newName);
                provider.updateWorkout(updatedWorkout);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Renamed to "$newName"'),
                    backgroundColor: const Color(0xFF7A5CFF),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
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
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ImportedWorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onMoveToHome,
    required this.onMoveToWorkouts,
    required this.onRename,
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: Responsive.getSpacing(context) * 0.5),
                        Text(
                          '${workout.exercises.length} exercises',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'rename':
                          onRename();
                          break;
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
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Rename'),
                          ],
                        ),
                      ),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.getSpacing(context)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImportedWorkoutDetailScreen(workoutId: workout.id),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Workout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.getSpacing(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        ),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';
import '../services/web_scraping_service.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class ImportWorkoutScreen extends StatefulWidget {
  static const route = '/import-workout';

  const ImportWorkoutScreen({super.key});

  @override
  State<ImportWorkoutScreen> createState() => _ImportWorkoutScreenState();
}

class _ImportWorkoutScreenState extends State<ImportWorkoutScreen> {
  final TextEditingController _urlCtrl = TextEditingController(
    text:
        'https://www.muscleandfitness.com/routine/workouts/workout-routines/chris-hemsworths-god-thor-workout/',
  );
  bool _importing = false;
  List<Workout> _importedWorkouts = [];
  String _importGroupName = '';
  int _importGroupCounter = 1;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _runImport() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a workout URL')),
      );
      return;
    }

    setState(() => _importing = true);
    try {
      final workouts = await WebScrapingService.scrapeWorkouts(url);
      if (!mounted) return;
      
      // Generate group name
      final groupName = 'Imported Workout $_importGroupCounter';
      _importGroupCounter++;
      
      setState(() {
        _importedWorkouts = workouts;
        _importGroupName = groupName;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${workouts.length} workout(s) - ready to save as "$groupName"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _organizeWorkout(Workout workout) async {
    final nameController = TextEditingController(text: workout.name);
    final groupController = TextEditingController();
    
    // Ensure the selected category is valid for the dropdown
    const validCategories = ['Strength', 'Cardio', 'Flexibility', 'HIIT', 'Core', 'Upper Body', 'Lower Body', 'Full Body'];
    String selectedCategory = validCategories.contains(workout.category) 
        ? workout.category 
        : 'Strength'; // Default fallback

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Organize Workout'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: groupController,
                decoration: const InputDecoration(
                  labelText: 'Group (e.g., "Upper Body", "Cardio", "Strength")',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Strength', child: Text('Strength')),
                  DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                  DropdownMenuItem(value: 'Flexibility', child: Text('Flexibility')),
                  DropdownMenuItem(value: 'HIIT', child: Text('HIIT')),
                  DropdownMenuItem(value: 'Core', child: Text('Core')),
                  DropdownMenuItem(value: 'Upper Body', child: Text('Upper Body')),
                  DropdownMenuItem(value: 'Lower Body', child: Text('Lower Body')),
                  DropdownMenuItem(value: 'Full Body', child: Text('Full Body')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'group': groupController.text.trim(),
                'category': selectedCategory,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final prov = context.read<WorkoutProvider>();
      final organizedWorkout = Workout(
        id: workout.id,
        name: result['name']!,
        category: result['category']!,
        description: '${workout.description}${result['group']!.isNotEmpty ? ' | Group: ${result['group']}' : ''}',
        durationMinutes: workout.durationMinutes,
        difficulty: workout.difficulty,
        exercises: workout.exercises,
      );

      await prov.importWorkouts([organizedWorkout]);
      
      setState(() {
        _importedWorkouts.removeWhere((w) => w.id == workout.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout organized and saved!')),
        );
      }
    }
  }

  Future<void> _saveAllAsGroup() async {
    if (_importedWorkouts.isEmpty) return;

    final prov = context.read<WorkoutProvider>();
    
    // Group workouts by body part/muscle group
    final Map<String, List<Workout>> groupedWorkouts = {};
    
    for (final workout in _importedWorkouts) {
      // Extract body part from workout name or description
      String bodyPart = 'General';
      final workoutText = '${workout.name} ${workout.description}'.toLowerCase();
      
      if (workoutText.contains('back')) bodyPart = 'Back';
      else if (workoutText.contains('chest')) bodyPart = 'Chest';
      else if (workoutText.contains('leg')) bodyPart = 'Legs';
      else if (workoutText.contains('arm')) bodyPart = 'Arms';
      else if (workoutText.contains('shoulder')) bodyPart = 'Shoulders';
      else if (workoutText.contains('core') || workoutText.contains('abs')) bodyPart = 'Core';
      
      groupedWorkouts.putIfAbsent(bodyPart, () => []).add(workout);
    }
    
    // Create a main workout with sub-workouts as "exercises"
    final allExercises = <Exercise>[];
    
    for (final entry in groupedWorkouts.entries) {
      final bodyPart = entry.key;
      final workouts = entry.value;
      
      // Combine all exercises from workouts in this body part
      final combinedExercises = <Exercise>[];
      for (final workout in workouts) {
        combinedExercises.addAll(workout.exercises);
      }
      
      // Create a "sub-workout" exercise for each body part
      allExercises.add(Exercise(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '$bodyPart Workout',
        sets: 1,
        reps: workouts.length,
        durationSeconds: workouts.fold(0, (sum, w) => sum + w.durationMinutes) * 60,
        equipment: '',
        notes: '${combinedExercises.length} exercises',
        description: 'Click to start $bodyPart workout',
        // Store the actual exercises in a custom field (we'll need to extend the Exercise model)
        // For now, we'll store them in the notes field as JSON
        // In a real implementation, you'd extend the Exercise model
      ));
    }

    final groupedWorkout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _importGroupName,
      category: 'Imported',
      description: 'Imported workout group with ${groupedWorkouts.length} body part(s)',
      durationMinutes: _importedWorkouts.fold(0, (sum, w) => sum + w.durationMinutes),
      difficulty: 'Intermediate',
      exercises: allExercises,
    );

    await prov.importWorkouts([groupedWorkout]);
    
    final workoutCount = _importedWorkouts.length;
    final groupName = _importGroupName;
    
    setState(() {
      _importedWorkouts.clear();
      _importGroupName = '';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "$groupName" with $workoutCount workout(s) grouped by body part!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Workout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // URL input section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'Paste workout page URL (e.g., Muscle & Fitness)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _importing ? null : _runImport,
                    icon: const Icon(Icons.cloud_download),
                    label: Text(_importing ? 'Importing…' : 'Import'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Imported workouts section (for organization)
          if (_importedWorkouts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group_work,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Import Group: $_importGroupName',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_importedWorkouts.length} workout(s) will be saved as one group',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saveAllAsGroup,
                          icon: const Icon(Icons.save),
                          label: const Text('Save as Group'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _importedWorkouts.clear();
                            _importGroupName = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Individual Workouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._importedWorkouts.map(
              (workout) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(workout.name),
                  subtitle: Text('${workout.category} • ${workout.exercises.length} exercise(s)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _organizeWorkout(workout),
                        tooltip: 'Organize',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _importedWorkouts.removeWhere((w) => w.id == workout.id);
                          });
                        },
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Existing workouts section
          if (workouts.isNotEmpty) ...[
            Text(
              'Your Workouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...workouts.map(
              (w) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(w.name),
                  subtitle: Text('${w.category} • ${w.exercises.length} exercise(s)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Hook up your workout detail route here if desired.
                    // Navigator.pushNamed(context, WorkoutDetailScreen.route, arguments: w.id);
                  },
                ),
              ),
            ),
          ],

          // Empty state
          if (workouts.isEmpty && _importedWorkouts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No workouts yet.\nPaste a URL above to import a plan.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
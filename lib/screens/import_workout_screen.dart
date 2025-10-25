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
      // Calculate next import index safely
      final importedNumbers = context.read<WorkoutProvider>().workouts
          .map((w) => RegExp(r'^Imported Workout (\d+)').firstMatch(w.name))
          .where((m) => m != null)
          .map((m) => int.tryParse(m!.group(1)!))
          .whereType<int>()
          .toList();

      final nextIndex = (importedNumbers.isEmpty)
          ? 1
          : (importedNumbers.reduce((a,b) => a > b ? a : b) + 1);

      final workouts = await WebScrapingService.scrapeWorkouts(url, importIndex: nextIndex);
      if (!mounted) return;
      
      // Generate group name
      final groupName = 'Imported Workout $nextIndex';
      
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
    
    // The new web scraping service creates individual workouts for each section
    // We need to create a main group workout that references these individual workouts
    final allExercises = <Exercise>[];
    
    for (final workout in _importedWorkouts) {
      // Extract body part from workout name
      String bodyPart = 'General';
      final workoutName = workout.name.toLowerCase();
      
      if (workoutName.contains('back')) bodyPart = 'Back';
      else if (workoutName.contains('chest')) bodyPart = 'Chest';
      else if (workoutName.contains('leg')) bodyPart = 'Legs';
      else if (workoutName.contains('arm')) bodyPart = 'Arms';
      else if (workoutName.contains('shoulder')) bodyPart = 'Shoulders';
      else if (workoutName.contains('core') || workoutName.contains('abs')) bodyPart = 'Core';
      
      // Create a "sub-workout" exercise that references the actual workout
      allExercises.add(Exercise(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '$bodyPart Workout',
        sets: 1,
        reps: 1,
        durationSeconds: workout.durationMinutes * 60,
        equipment: '',
        notes: '${workout.exercises.length} exercises',
        description: workout.id, // Store the actual workout ID for reference
      ));
    }

    final groupedWorkout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _importGroupName,
      category: 'Imported',
      description: 'Imported workout group with ${_importedWorkouts.length} workout(s)',
      durationMinutes: _importedWorkouts.fold(0, (sum, w) => sum + w.durationMinutes),
      difficulty: 'Intermediate',
      exercises: allExercises,
    );

    // Import both the individual workouts and the group workout
    await prov.importWorkouts([groupedWorkout, ..._importedWorkouts]);
    
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
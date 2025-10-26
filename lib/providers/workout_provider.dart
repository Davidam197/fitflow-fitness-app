import 'package:flutter/foundation.dart';
import '../data/workout_repo.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepo _repo;
  List<Workout> _workouts = [];

  WorkoutProvider(this._repo);

  List<Workout> get workouts => _workouts;

  Future<void> init() async {
    await _repo.seedIfEmpty();
    _workouts = await _repo.getAll();
    notifyListeners();
  }

  Workout byId(String id) => _workouts.firstWhere((w) => w.id == id);

  Future<void> saveWorkout(Workout w) async {
    await _repo.upsert(w);
    await refresh();
  }

  Future<void> refresh() async {
    _workouts = await _repo.getAll();
    notifyListeners();
  }

  Future<void> incrementSet(String workoutId, String exerciseId) async {
    final w = byId(workoutId);
    final ex = w.exercises.firstWhere((e) => e.id == exerciseId);
    if (ex.completedSets < ex.sets) {
      ex.completedSets++;
      await _repo.upsert(w);
      await refresh();
    }
  }

  Future<void> toggleCompleteExercise(String workoutId, String exerciseId) async {
    final w = byId(workoutId);
    final ex = w.exercises.firstWhere((e) => e.id == exerciseId);
    ex.completedSets = ex.isDone ? 0 : ex.sets;
    await _repo.upsert(w);
    await refresh();
  }

  Future<void> resetWorkout(String workoutId) async {
    final w = byId(workoutId);
    w.resetProgress();
    await _repo.upsert(w);
    await refresh();
  }

  Future<void> addExercise(String workoutId, Exercise e) async {
    final w = byId(workoutId);
    w.exercises.add(e);
    await _repo.upsert(w);
    await refresh();
  }

  Future<void> saveExerciseHowTo(String workoutId, String exerciseId, String howTo) async {
    final w = byId(workoutId);
    final ex = w.exercises.firstWhere((e) => e.id == exerciseId);
    ex.howTo = howTo;
    await _repo.upsert(w);
    await refresh();
  }

  Future<void> importWorkouts(List<Workout> workouts) async {
    final existingNames = _workouts.map((w) => w.name.toLowerCase()).toSet();
    final toAdd = <Workout>[];

    for (final w in workouts) {
      final key = w.name.toLowerCase();
      if (!existingNames.contains(key)) {
        // Ensure imported workouts have the proper description for filtering
        final importedWorkout = Workout(
          id: w.id,
          name: w.name,
          category: w.category,
          description: w.description.contains('Imported from web') 
              ? w.description 
              : '${w.description} (Imported from web)',
          durationMinutes: w.durationMinutes,
          difficulty: w.difficulty,
          exercises: w.exercises,
        );
        toAdd.add(importedWorkout);
        existingNames.add(key);
      } else {
        // Handle duplicates by modifying the name but keeping the imported description
        toAdd.add(Workout(
          id: w.id,
          name: '${w.name} (Imported)',
          category: w.category,
          description: w.description.contains('Imported from web') 
              ? w.description 
              : '${w.description} (Imported from web)',
          durationMinutes: w.durationMinutes,
          difficulty: w.difficulty,
          exercises: w.exercises,
        ));
      }
    }

    _workouts.addAll(toAdd);
    
    // Save all imported workouts to the database
    for (final workout in toAdd) {
      await _repo.upsert(workout);
    }
    
    notifyListeners();
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _repo.delete(workoutId);
    _workouts.removeWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _repo.upsert(workout);
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      notifyListeners();
    }
  }
}

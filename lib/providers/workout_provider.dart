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
}

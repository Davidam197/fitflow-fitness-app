import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // Strength, Cardio, Core, ...

  @HiveField(3)
  String description;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  String difficulty; // Easy/Medium/Hard

  @HiveField(6)
  List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.durationMinutes = 0,
    this.difficulty = 'Medium',
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  int get totalExercises => exercises.length;

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  int get completedSets => exercises.fold(0, (sum, e) => sum + e.completedSets);

  double get progress =>
      totalSets == 0 ? 0 : completedSets / totalSets; // 0..1

  int get progressPercent => (progress * 100).round();

  bool get isNotStarted => completedSets == 0;

  bool get isCompleted => totalSets > 0 && completedSets >= totalSets;

  String get primaryAction {
    if (isCompleted) return 'Restart';
    if (isNotStarted) return 'Start';
    return 'Continue';
  }

  void resetProgress() {
    for (final e in exercises) {
      e.completedSets = 0;
    }
  }

  Workout copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? durationMinutes,
    String? difficulty,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      exercises: exercises ?? this.exercises,
    );
  }
}

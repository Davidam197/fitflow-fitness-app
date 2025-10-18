import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int sets;

  @HiveField(3)
  int reps;

  @HiveField(4)
  int durationSeconds;

  @HiveField(5)
  String equipment;

  @HiveField(6)
  String notes;

  @HiveField(7)
  String description;

  @HiveField(8)
  int completedSets;

  @HiveField(9)
  String? howTo; // cached AI-generated instructions (markdown/text)

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.durationSeconds = 0,
    this.equipment = '',
    this.notes = '',
    this.description = '',
    this.completedSets = 0,
    this.howTo,
  });

  double get progress => sets == 0 ? 0 : completedSets / sets;

  bool get isDone => completedSets >= sets;

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    int? durationSeconds,
    String? equipment,
    String? notes,
    String? description,
    int? completedSets,
    String? howTo,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      completedSets: completedSets ?? this.completedSets,
      howTo: howTo ?? this.howTo,
    );
  }
}

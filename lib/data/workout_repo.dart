import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class WorkoutRepo {
  static const boxName = 'workouts_box';
  final _uuid = const Uuid();

  Future<Box<Workout>> _box() async => Hive.openBox<Workout>(boxName);

  Future<List<Workout>> getAll() async {
    final box = await _box();
    return box.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> upsert(Workout w) async {
    final box = await _box();
    await box.put(w.id, w);
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  /// Seed example workouts if empty (all at 0%)
  Future<void> seedIfEmpty() async {
    final box = await _box();
    if (box.isNotEmpty) return;

    final w1 = Workout(
      id: _uuid.v4(),
      name: 'Upper Body Blast',
      category: 'Strength',
      durationMinutes: 45,
      difficulty: 'Hard',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Bench Press', sets: 3, reps: 10, description: 'Lie flat on bench, grip bar slightly wider than shoulders. Lower bar to chest with control, then press up explosively. Keep core tight and maintain neutral spine throughout.'),
        Exercise(id: _uuid.v4(), name: 'Pull-ups', sets: 3, reps: 10, description: 'Hang from bar with overhand grip, hands shoulder-width apart. Pull body up until chin clears bar, then lower with control. Engage lats and keep core tight.'),
        Exercise(id: _uuid.v4(), name: 'Shoulder Press', sets: 3, reps: 10, description: 'Start with dumbbells at shoulder level, palms facing forward. Press weights straight up overhead until arms are fully extended, then lower with control.'),
        Exercise(id: _uuid.v4(), name: 'Rows', sets: 3, reps: 10, description: 'Bend forward at hips, keep back straight. Pull weight to lower chest, squeezing shoulder blades together. Control the weight on the way down.'),
        Exercise(id: _uuid.v4(), name: 'Bicep Curls', sets: 3, reps: 12, description: 'Stand with feet hip-width apart, hold dumbbells at sides. Curl weights up by flexing biceps, keeping elbows close to body. Lower with control.'),
        Exercise(id: _uuid.v4(), name: 'Tricep Dips', sets: 3, reps: 12, description: 'Sit on edge of bench, hands gripping edge. Slide forward and lower body by bending elbows, then press back up. Keep body close to bench.'),
        Exercise(id: _uuid.v4(), name: 'Lat Raise', sets: 2, reps: 15, description: 'Hold dumbbells at sides, palms facing body. Raise arms out to sides until parallel to floor, then lower with control. Keep slight bend in elbows.'),
        Exercise(id: _uuid.v4(), name: 'Push-ups', sets: 2, reps: 20, description: 'Start in plank position, hands slightly wider than shoulders. Lower chest to ground, then push back up. Keep body in straight line throughout.'),
      ],
    );

    final w2 = Workout(
      id: _uuid.v4(),
      name: 'HIIT Cardio',
      category: 'Cardio',
      durationMinutes: 20,
      difficulty: 'Hard',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Burpees', sets: 3, reps: 15, description: 'Start standing, drop to push-up position, do a push-up, jump feet to hands, then jump up with arms overhead. Land softly and repeat immediately.'),
        Exercise(id: _uuid.v4(), name: 'Mountain Climbers', sets: 3, reps: 30, description: 'Start in plank position. Alternate bringing knees to chest rapidly, keeping hips level. Maintain strong core and quick pace.'),
        Exercise(id: _uuid.v4(), name: 'Jump Squats', sets: 3, reps: 15, description: 'Start with feet shoulder-width apart. Lower into squat, then explode up into jump. Land softly and immediately go into next squat.'),
        Exercise(id: _uuid.v4(), name: 'High Knees', sets: 3, reps: 45, description: 'Run in place, bringing knees up to hip level. Pump arms naturally and maintain quick pace. Keep core engaged throughout.'),
        Exercise(id: _uuid.v4(), name: 'Plank', sets: 3, reps: 60, description: 'Hold push-up position with forearms on ground. Keep body in straight line from head to heels. Engage core and breathe normally.'),
        Exercise(id: _uuid.v4(), name: 'Sprints', sets: 3, reps: 30, description: 'Run at maximum effort for specified time. Focus on quick turnover and powerful arm drive. Rest between sets for full recovery.'),
      ],
    );

    final w3 = Workout(
      id: _uuid.v4(),
      name: 'Core Destroyer',
      category: 'Core',
      durationMinutes: 30,
      difficulty: 'Hard',
      exercises: [
        Exercise(id: _uuid.v4(), name: 'Crunches', sets: 5, reps: 20, description: 'Lie on back, knees bent, feet flat. Place hands behind head. Lift shoulders off ground by contracting abs. Lower with control and repeat.'),
        Exercise(id: _uuid.v4(), name: 'Leg Raises', sets: 5, reps: 15, description: 'Lie on back, legs straight. Lift legs up to 90 degrees, then lower slowly without touching ground. Keep lower back pressed to floor.'),
        Exercise(id: _uuid.v4(), name: 'Plank', sets: 5, reps: 60, description: 'Hold push-up position with forearms on ground. Keep body in straight line from head to heels. Engage core and breathe normally.'),
      ],
    );

    await box.putAll({w1.id: w1, w2.id: w2, w3.id: w3});
  }
}

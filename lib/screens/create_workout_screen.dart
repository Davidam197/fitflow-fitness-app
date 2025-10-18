import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../providers/membership_provider.dart';
import 'add_exercise_screen.dart';

class CreateWorkoutScreen extends StatefulWidget {
  static const route = '/create';
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _form = GlobalKey<FormState>();
  final _uuid = const Uuid();
  String name = '';
  String category = 'Strength';
  String description = '';
  String difficulty = 'Medium';
  int duration = 30;

  bool routineMode = false; // false = Standalone, true = Routine
  final exercises = <dynamic>[];
  final routineDays = <_RoutineDay>[]; // UI only container for days

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        actions: [
          TextButton(
            onPressed: () async {
              if (!_form.currentState!.validate()) return;
              _form.currentState!.save();

              // Check workout limit for basic users
              final membershipProvider = context.read<MembershipProvider>();
              final maxWorkouts = membershipProvider.getMaxWorkouts();
              
              if (maxWorkouts != -1 && prov.workouts.length >= maxWorkouts) {
                _showUpgradeDialog(context, 'Workout Limit Reached', 
                  'You\'ve reached the maximum of $maxWorkouts workouts on the Basic plan. Upgrade to Premium for unlimited workouts!');
                return;
              }

              // If routine mode, flatten all day exercises
              final allExercises = routineMode
                  ? routineDays.expand((d) => d.exercises).toList()
                  : exercises.cast();

              final w = Workout(
                id: _uuid.v4(),
                name: name,
                category: category,
                description: description,
                durationMinutes: duration,
                difficulty: difficulty,
                exercises: allExercises.cast(),
              );
              await prov.saveWorkout(w);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
      floatingActionButton: (!routineMode)
          ? _FABAdd(onTap: () async {
              // Check exercise limit for basic users
              final membershipProvider = context.read<MembershipProvider>();
              final maxExercises = membershipProvider.getMaxExercisesPerWorkout();
              
              if (maxExercises != -1 && exercises.length >= maxExercises) {
                _showUpgradeDialog(context, 'Exercise Limit Reached', 
                  'You\'ve reached the maximum of $maxExercises exercises per workout on the Basic plan. Upgrade to Premium for unlimited exercises!');
                return;
              }

              final res = await Navigator.pushNamed(context, AddExerciseScreen.route)
                  as Map<String, dynamic>?;
              if (res != null) setState(() => exercises.add(res['exercise']));
            })
          : null,
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Basic Information',
              child: Column(children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Workout Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'Strength', child: Text('Strength')),
                    DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                    DropdownMenuItem(value: 'Core', child: Text('Core')),
                    DropdownMenuItem(value: 'Mobility', child: Text('Mobility')),
                  ],
                  onChanged: (v) => setState(() => category = v as String),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  minLines: 2, maxLines: 3,
                  onSaved: (v) => description = v?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: difficulty,
                      items: const [
                        DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                      ],
                      onChanged: (v) => setState(() => difficulty = v as String),
                      decoration: const InputDecoration(labelText: 'Difficulty'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Duration (min)'),
                      keyboardType: TextInputType.number,
                      initialValue: '30',
                      onSaved: (v) => duration = int.tryParse(v ?? '30') ?? 30,
                    ),
                  ),
                ]),
              ]),
            ),

            const SizedBox(height: 12),
            _SectionCard(
              title: 'Workout Type',
              child: Row(children: [
                Expanded(
                  child: _SelectTile(
                    title: 'Standalone',
                    subtitle: 'Single session workout',
                    icon: Icons.fitness_center,
                    active: !routineMode,
                    activeColor: const Color(0xFFDAF5EB),
                    borderColor: Colors.green,
                    onTap: () => setState(() => routineMode = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectTile(
                    title: 'Routine',
                    subtitle: 'Multi-day workout plan',
                    icon: Icons.calendar_month,
                    active: routineMode,
                    activeColor: const Color(0xFFF0E9FF),
                    borderColor: Colors.purple,
                    onTap: () => setState(() => routineMode = true),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 12),
            if (!routineMode)
              _SectionCard(
                title: 'Exercises',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RowHeader(
                      left: const Text('Day 1',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      right: FilledButton.tonal(
                        onPressed: () async {
                          final res = await Navigator.pushNamed(
                            context, AddExerciseScreen.route) as Map<String, dynamic>?;
                          if (res != null) setState(() => exercises.add(res['exercise']));
                        },
                        child: const Text('Edit Exercises'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (exercises.isEmpty)
                      _EmptyHint(text: '0 exercises'),
                    ...exercises.map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE9EEFF),
                              child: Icon(Icons.fitness_center, color: Colors.blue)),
                          title: Text(e.name),
                          subtitle: Text('${e.sets} sets × ${e.reps} reps'),
                        )),
                  ],
                ),
              )
            else
              _RoutineEditor(
                days: routineDays,
                onAddDay: () => setState(() => routineDays.add(_RoutineDay.empty())),
                onAddExercise: (day) async {
                  // Check exercise limit for basic users
                  final membershipProvider = context.read<MembershipProvider>();
                  final maxExercises = membershipProvider.getMaxExercisesPerWorkout();
                  
                  if (maxExercises != -1 && day.exercises.length >= maxExercises) {
                    _showUpgradeDialog(context, 'Exercise Limit Reached', 
                      'You\'ve reached the maximum of $maxExercises exercises per workout on the Basic plan. Upgrade to Premium for unlimited exercises!');
                    return;
                  }

                  final res = await Navigator.pushNamed(context, AddExerciseScreen.route)
                      as Map<String, dynamic>?;
                  if (res != null) setState(() => day.exercises.add(res['exercise']));
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to settings to upgrade
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }
}

/// UI PARTS

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.settings_suggest_outlined, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final bool active;
  final Color borderColor, activeColor;
  final VoidCallback onTap;
  const _SelectTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.borderColor,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? borderColor : Colors.grey.shade300, width: 2),
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE9EEFF),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ])),
        ]),
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  final Widget left; final Widget? right;
  const _RowHeader({required this.left, this.right});
  @override
  Widget build(BuildContext context) {
    return Row(children: [left, const Spacer(), if (right != null) right!]);
  }
}

class _FABAdd extends StatelessWidget {
  final VoidCallback onTap;
  const _FABAdd({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add Exercise', style: TextStyle(color: Colors.white)),
      shape: const StadiumBorder(),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.event_note, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }
}

class _RoutineDay {
  String name;
  final List<dynamic> exercises;
  _RoutineDay({required this.name, required this.exercises});
  factory _RoutineDay.empty() => _RoutineDay(name: 'Day ${DateTime.now().millisecondsSinceEpoch % 100}', exercises: []);
}

class _RoutineEditor extends StatelessWidget {
  final List<_RoutineDay> days;
  final VoidCallback onAddDay;
  final Future<void> Function(_RoutineDay day) onAddExercise;
  const _RoutineEditor({required this.days, required this.onAddDay, required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Workout Days',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _RowHeader(
          left: const SizedBox(),
          right: TextButton.icon(onPressed: onAddDay, icon: const Icon(Icons.add), label: const Text('Add Day')),
        ),
        const SizedBox(height: 6),
        if (days.isEmpty) const _EmptyHint(text: 'No workout days added yet\nTap "Add Day" to create your first workout day'),
        ...days.map((d) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...d.exercises.map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE9EEFF),
                            child: Icon(Icons.fitness_center, color: Colors.blue)),
                        title: Text(e.name),
                        subtitle: Text('${e.sets} sets × ${e.reps} reps'),
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: () => onAddExercise(d),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  )
                ]),
              ),
            )),
      ]),
    );
  }
}
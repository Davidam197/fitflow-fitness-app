import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../widgets/ff_widgets.dart';
import '../services/ai_instructions_service.dart';
import '../utils/responsive.dart';

class WorkoutDetailScreen extends StatelessWidget {
  static const route = '/workout';
  const WorkoutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutId = ModalRoute.of(context)!.settings.arguments as String;
    final prov = context.watch<WorkoutProvider>();
    final Workout w = prov.byId(workoutId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getSpacing(context)),
        children: [
          _Header(w: w),
          SizedBox(height: Responsive.getSpacing(context)),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive grid based on screen width
              final screenWidth = constraints.maxWidth;
              final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns on tablets, 2 on phones
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: w.exercises.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: screenWidth > 600 ? 1.1 : 0.85, // Better aspect ratio for tablets
                  crossAxisSpacing: Responsive.getSpacing(context) * 0.75,
                  mainAxisSpacing: Responsive.getSpacing(context) * 0.75,
                ),
                itemBuilder: (ctx, i) => _ExerciseTile(workoutId: w.id, index: i),
              );
            },
          ),
          SizedBox(height: Responsive.getSpacing(context) * 1.5),
          if (w.isCompleted)
            FilledButton(
              onPressed: () => prov.resetWorkout(w.id),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.getSpacing(context),
                  horizontal: Responsive.getSpacing(context) * 1.5,
                ),
              ),
              child: Text(
                'Restart Workout',
                style: TextStyle(
                  fontSize: Responsive.getBodyFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Workout w;
  const _Header({required this.w});

  @override
  Widget build(BuildContext context) {
    return FFGradientCard(
      colors: const [Color(0xFF9B57FF), Color(0xFFEB63A3)],
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Text('💪')),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              w.name, 
              style: TextStyle(
                fontSize: Responsive.getTitleFontSize(context),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(
              w.category,
              style: TextStyle(
                fontSize: Responsive.getBodyFontSize(context) * 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.edit, color: Colors.white70),
        ]),
        const SizedBox(height: 18),
        Text(
          'Workout Progress', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w700,
            fontSize: Responsive.getSubtitleFontSize(context),
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: w.progress.clamp(0,1)),
        const SizedBox(height: 6),
        Text(
          '${w.progressPercent}% Complete',
          style: TextStyle(
            color: Colors.white70,
            fontSize: Responsive.getBodyFontSize(context) * 0.9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _mini('🏋️', '${w.completedSets}/${w.totalSets}', 'Sets Done'),
          _mini('🧘', '${w.totalExercises}', 'Exercises'),
          _mini('📁', 'Active Workout', 'Source'),
        ]),
      ]),
    );
  }

  Widget _mini(String emoji, String value, String label) {
    return Builder(
      builder: (context) => Column(children: [
        Text(
          value, 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w800, 
            fontSize: Responsive.getSubtitleFontSize(context),
          ),
        ),
        Text(
          label, 
          style: TextStyle(
            color: Colors.white70,
            fontSize: Responsive.getBodyFontSize(context) * 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ]),
    );
  }
}

class _ExerciseTile extends StatefulWidget {
  final String workoutId;
  final int index;
  const _ExerciseTile({required this.workoutId, required this.index});

  @override
  State<_ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<_ExerciseTile> {
  bool _loadingHowTo = false;

  @override
  void initState() {
    super.initState();
    // Auto-load instructions when card is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstructions();
    });
  }

  Future<void> _loadInstructions() async {
    final prov = context.read<WorkoutProvider>();
    final w = prov.byId(widget.workoutId);
    final ex = w.exercises[widget.index];

    // Only load if not already cached
    if (ex.howTo == null || ex.howTo!.isEmpty) {
      setState(() => _loadingHowTo = true);
      try {
        // Use a fallback instruction instead of API call for now
        final fallbackInstructions = _getFallbackInstructions(ex.name, ex.sets, ex.reps);
        await prov.saveExerciseHowTo(w.id, ex.id, fallbackInstructions);
      } catch (e) {
        if (!mounted) return;
        // Use fallback instructions even if save fails
        final fallbackInstructions = _getFallbackInstructions(ex.name, ex.sets, ex.reps);
        await prov.saveExerciseHowTo(w.id, ex.id, fallbackInstructions);
      } finally {
        if (mounted) setState(() => _loadingHowTo = false);
      }
    }
  }

  String _getFallbackInstructions(String exerciseName, int sets, int reps) {
    final instructions = {
      'Plank': '''• Start in push-up position with forearms on ground
• Keep body in straight line from head to heels
• Engage core and breathe normally
• Hold position for specified time
• Avoid sagging hips or raised buttocks
• Keep shoulders directly over elbows''',
      'Bench Press': '''• Lie flat on bench, grip bar slightly wider than shoulders
• Lower bar to chest with control
• Press up explosively while keeping core tight
• Keep feet flat on floor
• Maintain neutral spine throughout
• Control the weight on both descent and ascent''',
      'Push-ups': '''• Start in plank position, hands slightly wider than shoulders
• Lower chest to ground by bending elbows
• Push back up to starting position
• Keep body in straight line throughout
• Engage core and glutes
• Breathe out on the push, in on the descent''',
    };
    
    return instructions[exerciseName] ?? '''• Set up in proper starting position
• Execute movement with control and good form
• Focus on breathing rhythm
• Complete ${sets} sets of ${reps} reps
• Rest 60-90 seconds between sets
• Maintain proper posture throughout''';
  }

  Future<void> _showHowTo(BuildContext context) async {
    final prov = context.read<WorkoutProvider>();
    final w = prov.byId(widget.workoutId);
    final ex = w.exercises[widget.index];

    // Already cached?
    if (ex.howTo == null) {
      setState(() => _loadingHowTo = true);
      try {
        // TODO: inject your key via constructor or service locator
        final ai = AIInstructionsService(apiKey: const String.fromEnvironment('OPENAI_KEY'));
        final text = await ai.generate(
          exerciseName: ex.name,
          sets: ex.sets,
          reps: ex.reps,
          category: w.category,
          equipment: ex.equipment,
        );
        await prov.saveExerciseHowTo(w.id, ex.id, text);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get guide: $e')),
        );
      } finally {
        if (mounted) setState(() => _loadingHowTo = false);
      }
    }

    // Show bottom sheet with the cached text
    final refreshed = prov.byId(widget.workoutId);
    final latest = refreshed.exercises[widget.index];

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.menu_book_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${latest.name} — How to perform',
                      style: Theme.of(context).textTheme.titleMedium)),
                ],
              ),
              const SizedBox(height: 12),
              if (_loadingHowTo) const LinearProgressIndicator(),
              SelectableText(
                latest.howTo ?? 'No guide available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTimer(BuildContext context) {
    final prov = context.read<WorkoutProvider>();
    final w = prov.byId(widget.workoutId);
    final ex = w.exercises[widget.index];
    final initial = (ex.durationSeconds > 0 ? ex.durationSeconds : 60);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TimerSheet(initialSeconds: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final w = prov.byId(widget.workoutId);
    final ex = w.exercises[widget.index];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.getSpacing(context) * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          children: [
            // Header with icon and name
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE9EEFF), 
                  child: Icon(Icons.fitness_center, color: Colors.blue, size: 16)
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ex.name,
                    style: TextStyle(
                      fontSize: Responsive.getBodyFontSize(context) * 0.9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E1625),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Exercise guide',
                  onPressed: _loadingHowTo ? null : () => _showHowTo(context),
                  icon: Icon(
                    ex.howTo != null && ex.howTo!.isNotEmpty 
                      ? Icons.menu_book 
                      : Icons.menu_book_outlined, 
                    color: ex.howTo != null && ex.howTo!.isNotEmpty 
                      ? Colors.blue 
                      : const Color(0xFF707B90),
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            
            SizedBox(height: Responsive.getSpacing(context) * 0.5),
            
            // Sets and reps info
            Text(
              '${ex.sets} sets × ${ex.reps} reps', 
              style: TextStyle(
                fontSize: Responsive.getBodyFontSize(context) * 0.8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            SizedBox(height: Responsive.getSpacing(context) * 0.375),
            
            // Progress info
            Text(
              '${ex.completedSets}/${ex.sets}', 
              style: TextStyle(
                fontSize: Responsive.getBodyFontSize(context) * 0.8,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0E1625),
              ),
            ),
            
            SizedBox(height: Responsive.getSpacing(context) * 0.375),
            
            // Progress bar
            LinearProgressIndicator(
              value: ex.progress.clamp(0, 1), 
              backgroundColor: Colors.grey.shade300, 
              color: Colors.blue,
              minHeight: 4,
            ),
            
            SizedBox(height: Responsive.getSpacing(context) * 0.75),
            
            // Action buttons
            Row(
              children: [
                // Timer button
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openTimer(context),
                    icon: Icon(Icons.timer, size: Responsive.getIconSize(context) * 0.7),
                    label: Text(
                      'Timer', 
                      style: TextStyle(fontSize: Responsive.getBodyFontSize(context) * 0.75),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.getSpacing(context) * 0.75,
                        horizontal: Responsive.getSpacing(context) * 0.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.getSpacing(context) * 0.5),
                // Complete button
                SizedBox(
                  height: Responsive.getSpacing(context) * 2.5,
                  width: Responsive.getSpacing(context) * 2.5,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => prov.incrementSet(w.id, ex.id),
                    child: Icon(
                      Icons.check, 
                      color: Colors.white, 
                      size: Responsive.getIconSize(context) * 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSheet extends StatefulWidget {
  final int initialSeconds;
  const _TimerSheet({required this.initialSeconds});

  @override
  State<_TimerSheet> createState() => _TimerSheetState();
}

class _TimerSheetState extends State<_TimerSheet> {
  late int _seconds;
  Timer? _t;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _start() {
    _t?.cancel();
    setState(() => _running = true);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() {
          _seconds = 0;
          _running = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timer done')),
          );
        }
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _pause() {
    _t?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _t?.cancel();
    setState(() {
      _seconds = widget.initialSeconds;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String mmss(int s) {
      final m = (s ~/ 60).toString().padLeft(2, '0');
      final ss = (s % 60).toString().padLeft(2, '0');
      return '$m:$ss';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 46, height: 5,
              decoration: BoxDecoration(color: const Color(0xFFE1E6F2), borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 16),
          const Text('Set Timer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Use this to time your rest or time-under-tension', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Text(mmss(_seconds), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _running ? _pause : _start,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'Pause' : 'Start'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../screens/create_workout_screen.dart';
import '../screens/previous_workouts_screen.dart';
import '../widgets/ff_widgets.dart';
import '../navigation/navigation_controller.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isCardExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _autoCollapseTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Start with expanded state
    _animationController.forward();
    
    // Set timer to collapse after 1 minute
    _autoCollapseTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        _toggleCard();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _toggleCard() {
    setState(() {
      _isCardExpanded = !_isCardExpanded;
      if (_isCardExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final workouts = prov.workouts;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getSpacing(context),
            vertical: Responsive.getSpacing(context) * 0.5,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFA3C9FF), // Sky blue
                const Color(0xFFC9B8FF), // Lavender
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E6CF6).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FitFlow',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.getTitleFontSize(context),
                  color: const Color(0xFF0E1625), // Dark navy
                ),
              ),
              Text(
                'Your personal trainer',
                style: TextStyle(
                  fontSize: Responsive.getCaptionFontSize(context),
                  color: const Color(0xFF7C8AA3), // Subtext
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: Responsive.getSpacing(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3E6CF6), // Vibrant blue
                  const Color(0xFF7A5CFF), // Violet
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3E6CF6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, CreateWorkoutScreen.route),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8FAFF), // Soft gradient base
              const Color(0xFFE8F0FF), // Gradient end
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // Simulate refresh delay
            await Future.delayed(const Duration(seconds: 1));
            // In a real app, you would refresh data here
          },
          child: ListView(
            padding: Responsive.getScreenPadding(context),
            children: [
          // Collapsible greeting gradient banner
          GestureDetector(
            onTap: _toggleCard,
            child: FFGradientCard(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Good morning!', 
                                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                const Text('Ready to crush your goals?',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                              ],
                            ),
                          ),
                          Icon(
                            _isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      SizeTransition(
                        sizeFactor: _animation,
                        child: Column(
                          children: [
                            const SizedBox(height: 14),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                              _Stat(icon: Icons.task_alt, value: '1', label: 'Completed'),
                              _Stat(icon: Icons.access_time, value: '46m', label: 'Time Spent'),
                              _Stat(icon: Icons.local_fire_department, value: '7', label: 'Day Streak'),
                              _Stat(icon: Icons.fitness_center, value: '24', label: 'Total Done'),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to active workouts tab (index 2)
                  NavigationController.navigateToTab(2);
                },
                child: const FFIconPill(icon: Icons.fitness_center, title: 'Active Workouts', subtitle: 'View & Start', color: Colors.green),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to previous workouts screen
                  Navigator.pushNamed(context, PreviousWorkoutsScreen.route);
                },
                child: const FFIconPill(icon: Icons.history, title: 'Previous Workouts', subtitle: 'View History', color: Colors.orange),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          FFSectionHeader(
            title: 'Your Workouts', 
            onAction: () {
              // Navigate to workouts tab (index 1)
              NavigationController.navigateToTab(1);
            }
          ),
          ...workouts.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _WorkoutListCard(workoutId: w.id),
          )),
        ],
          ),
        ),
      ),
    );
  }

}

class _Stat extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _Stat({required this.icon, required this.value, required this.label});
  @override Widget build(BuildContext context) => Column(children: [
    Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: Colors.white70)),
  ]);
}

class _WorkoutListCard extends StatelessWidget {
  final String workoutId;
  const _WorkoutListCard({required this.workoutId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final w = prov.byId(workoutId);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: w.category == 'Cardio' 
            ? [const Color(0xFFE8F5E8), const Color(0xFFF0F9FF)]
            : [const Color(0xFFF3E8FF), const Color(0xFFE8F0FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: w.category == 'Cardio' 
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: w.category == 'Cardio' 
            ? Colors.green.withOpacity(0.3)
            : Colors.blue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: w.category == 'Cardio' 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(w.category == 'Cardio' ? '🏃' : '🏋️', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              )),
              Text(w.category, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: w.category == 'Cardio' ? Colors.green : Colors.blue,
                fontWeight: FontWeight.w600,
              )),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: w.category == 'Cardio' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${w.totalExercises - (w.totalExercises - w.exercises.length)}/${w.totalExercises} exercises',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: w.category == 'Cardio' ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${w.progressPercent}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: w.category == 'Cardio' ? Colors.green : Colors.blue,
              )),
              Text('Progress', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade300,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: w.progress.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: w.category == 'Cardio' 
                      ? [Colors.green, Colors.green.withOpacity(0.8)]
                      : [Colors.blue, Colors.blue.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: w.category == 'Cardio' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.access_time, size: 16, color: w.category == 'Cardio' ? Colors.green : Colors.blue),
            ),
            const SizedBox(width: 8),
            Text('${w.durationMinutes} min', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: w.category == 'Cardio' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.trending_up, size: 16, color: w.category == 'Cardio' ? Colors.green : Colors.blue),
            ),
            const SizedBox(width: 8),
            Text(w.difficulty, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: w.isCompleted
                  ? () => prov.resetWorkout(w.id)
                  : () => Navigator.pushNamed(context, '/workout', arguments: w.id),
              icon: Icon(w.isCompleted ? Icons.refresh : Icons.play_arrow),
              label: Text(w.primaryAction),
              style: FilledButton.styleFrom(
                backgroundColor: w.category == 'Cardio' ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

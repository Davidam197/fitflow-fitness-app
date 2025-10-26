import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../screens/workout_detail_screen.dart';
import 'create_workout_screen.dart';
import '../utils/responsive.dart';

class ActiveWorkoutsScreen extends StatelessWidget {
  const ActiveWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final activeWorkouts = prov.workouts.where((workout) => 
      !workout.isNotStarted && !workout.isCompleted
    ).toList();

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
                const Color(0xFF20C38B), // Fresh Green
                const Color(0xFF00BFA5), // Teal
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF20C38B).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.getSpacing(context) * 0.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF20C38B), // Fresh green
                      const Color(0xFF00BFA5), // Teal
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 0.5),
                ),
                child: Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: Responsive.getIconSize(context) * 0.7,
                ),
              ),
              SizedBox(width: Responsive.getSpacing(context) * 0.5),
              Text(
                'Active Workouts',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.getTitleFontSize(context),
                  color: Colors.white, // White for contrast
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: Responsive.getSpacing(context)),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getSpacing(context),
              vertical: Responsive.getSpacing(context) * 0.5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF20C38B), // Solid green
              borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF20C38B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: Responsive.getIconSize(context) * 0.6,
                ),
                SizedBox(width: Responsive.getSpacing(context) * 0.25),
                Text(
                  '${activeWorkouts.length} active',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: Responsive.getCaptionFontSize(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFA8F3B0), // Lime
              const Color(0xFFC5F9C0), // Light green
            ],
          ),
        ),
        child: activeWorkouts.isEmpty
            ? _EmptyState()
            : ListView.builder(
                padding: Responsive.getScreenPadding(context),
              itemCount: activeWorkouts.length,
              itemBuilder: (context, index) {
                final workout = activeWorkouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActiveWorkoutCard(workout: workout),
                );
              },
            ),
        ),
    );
  }
}

class _ActiveWorkoutCard extends StatelessWidget {
  final dynamic workout;

  const _ActiveWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: workout.category == 'Cardio' 
            ? [const Color(0xFFE8F5E8), const Color(0xFFF0F9FF)]
            : [const Color(0xFFF3E8FF), const Color(0xFFE8F0FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: workout.category == 'Cardio' 
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
          color: workout.category == 'Cardio' 
            ? Colors.green.withOpacity(0.3)
            : Colors.blue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, WorkoutDetailScreen.route, arguments: workout.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: workout.category == 'Cardio' 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        workout.category == 'Cardio' ? '🏃' : '🏋️',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: workout.category == 'Cardio' 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  workout.category,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'In Progress',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_filled,
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                      size: 32,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${workout.progressPercent}% Complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                      ),
                    ),
                    Text(
                      '${workout.completedSets}/${workout.totalSets} sets',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).dividerColor,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: workout.progress.clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: workout.category == 'Cardio' 
                            ? [Colors.green, Colors.green.withOpacity(0.8)]
                            : [Colors.blue, Colors.blue.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats row
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.access_time,
                      label: '${workout.durationMinutes} min',
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 24),
                    _StatItem(
                      icon: Icons.fitness_center,
                      label: '${workout.exercises.length} exercises',
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 24),
                    _StatItem(
                      icon: Icons.trending_up,
                      label: workout.difficulty,
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, WorkoutDetailScreen.route, arguments: workout.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continue Workout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a workout to see it here.\nYour progress will be tracked automatically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            // Navigate to create workout screen
            Navigator.pushNamed(context, CreateWorkoutScreen.route);
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Workout'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../screens/workout_detail_screen.dart';
import 'create_workout_screen.dart';
import '../widgets/fitflow_sliver_header.dart';
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
      body: CustomScrollView(
        slivers: [
          FitFlowSliverHeader(
            title: 'Active Workouts',
            subtitle: 'Pick up where you left off',
            actions: const [],
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          activeWorkouts.isEmpty
              ? SliverFillRemaining(
                  child: _EmptyState(),
                )
              : SliverPadding(
                  padding: Responsive.getScreenPadding(context),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final workout = activeWorkouts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ActiveWorkoutCard(workout: workout),
                        );
                      },
                      childCount: activeWorkouts.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.getSpacing(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.getSpacing(context) * 2),
              decoration: BoxDecoration(
                color: const Color(0xFF20C38B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_circle_outline,
                size: Responsive.getIconSize(context) * 2,
                color: const Color(0xFF20C38B),
              ),
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            Text(
              'No Active Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.getSpacing(context)),
            Text(
              'Start a workout to see it here. You can continue where you left off anytime.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.getSpacing(context) * 2),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, CreateWorkoutScreen.route),
              icon: const Icon(Icons.add),
              label: const Text('Create Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20C38B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSpacing(context) * 2,
                  vertical: Responsive.getSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                ),
              ),
            ),
          ],
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
    final progress = workout.progressPercentage ?? 0.0;
    final exercises = workout.exercises ?? [];
    final completedExercises = exercises.where((ex) => ex.isCompleted).length;
    final totalExercises = exercises.length;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.getSpacing(context),
        vertical: Responsive.getSpacing(context) * 0.5,
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          WorkoutDetailScreen.route,
          arguments: workout.id,
        ),
        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.getSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name ?? 'Workout',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.getSpacing(context) * 0.5),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getSpacing(context) * 0.5,
                                vertical: Responsive.getSpacing(context) * 0.25,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(workout.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 0.5),
                                border: Border.all(
                                  color: _getCategoryColor(workout.category).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                workout.category ?? 'General',
                                style: TextStyle(
                                  color: _getCategoryColor(workout.category),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: Responsive.getSpacing(context) * 0.5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getSpacing(context) * 0.5,
                                vertical: Responsive.getSpacing(context) * 0.25,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF20C38B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 0.5),
                                border: Border.all(
                                  color: const Color(0xFF20C38B).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Color(0xFF20C38B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_filled,
                    color: const Color(0xFF20C38B),
                    size: Responsive.getIconSize(context),
                  ),
                ],
              ),
              
              SizedBox(height: Responsive.getSpacing(context)),
              
              // Progress section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workout Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF20C38B),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.getSpacing(context) * 0.5),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: const Color(0xFF20C38B).withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20C38B)),
                    minHeight: 6,
                  ),
                  SizedBox(height: Responsive.getSpacing(context) * 0.5),
                  Text(
                    '$completedExercises of $totalExercises exercises completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              
              SizedBox(height: Responsive.getSpacing(context)),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: 'Duration',
                    value: '${workout.durationMinutes ?? 0} min',
                    icon: Icons.timer_outlined,
                  ),
                  _StatItem(
                    label: 'Difficulty',
                    value: workout.difficulty ?? 'Beginner',
                    icon: Icons.trending_up,
                  ),
                  _StatItem(
                    label: 'Exercises',
                    value: '$totalExercises',
                    icon: Icons.fitness_center,
                  ),
                ],
              ),
              
              SizedBox(height: Responsive.getSpacing(context)),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    WorkoutDetailScreen.route,
                    arguments: workout.id,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Continue Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20C38B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.getSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'cardio':
        return const Color(0xFF3ECF8E); // Green
      case 'strength':
        return const Color(0xFFFF6B6B); // Red/Pink
      case 'flexibility':
        return const Color(0xFF4E6CF8); // Blue
      case 'hiit':
        return const Color(0xFFFFA726); // Orange
      default:
        return const Color(0xFF7C8AA3); // Default gray
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: Responsive.getSpacing(context) * 0.25),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
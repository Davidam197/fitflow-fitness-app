import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../screens/workout_detail_screen.dart';

class PreviousWorkoutsScreen extends StatefulWidget {
  static const route = '/previous-workouts';
  const PreviousWorkoutsScreen({super.key});

  @override
  State<PreviousWorkoutsScreen> createState() => _PreviousWorkoutsScreenState();
}

class _PreviousWorkoutsScreenState extends State<PreviousWorkoutsScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  final List<String> _filters = ['All', 'This Week', 'This Month', 'This Year'];
  final List<String> _sortOptions = ['Recent', 'Name', 'Duration', 'Category'];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkoutProvider>();
    final completedWorkouts = prov.workouts.where((workout) => workout.isCompleted).toList();
    
    // Apply filters and sorting
    var filteredWorkouts = _applyFilters(completedWorkouts);
    filteredWorkouts = _applySorting(filteredWorkouts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Workouts'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${filteredWorkouts.length} completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    value: _selectedFilter,
                    options: _filters,
                    onChanged: (value) => setState(() => _selectedFilter = value!),
                    label: 'Filter',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterDropdown(
                    value: _selectedSort,
                    options: _sortOptions,
                    onChanged: (value) => setState(() => _selectedSort = value!),
                    label: 'Sort',
                  ),
                ),
              ],
            ),
          ),
          
          // Workouts List
          Expanded(
            child: filteredWorkouts.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = filteredWorkouts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PreviousWorkoutCard(workout: workout),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> workouts) {
    if (_selectedFilter == 'All') return workouts;
    
    return workouts.where((workout) {
      // For now, we'll use a simple approach since we don't have completion dates
      // In a real app, you'd store completion timestamps
      return true; // Placeholder - all completed workouts pass filter
    }).toList();
  }

  List<dynamic> _applySorting(List<dynamic> workouts) {
    switch (_selectedSort) {
      case 'Recent':
        // Sort by completion time (placeholder - most recent first)
        return workouts.reversed.toList();
      case 'Name':
        workouts.sort((a, b) => a.name.compareTo(b.name));
        return workouts;
      case 'Duration':
        workouts.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
        return workouts;
      case 'Category':
        workouts.sort((a, b) => a.category.compareTo(b.category));
        return workouts;
      default:
        return workouts;
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String label;

  const _FilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(
              option,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _PreviousWorkoutCard extends StatelessWidget {
  final dynamic workout;

  const _PreviousWorkoutCard({required this.workout});

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: workout.category == 'Cardio' 
              ? Colors.green.withOpacity(0.15)
              : Colors.blue.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: workout.category == 'Cardio' 
            ? Colors.green.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, WorkoutDetailScreen.route, arguments: workout.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                              fontWeight: FontWeight.w600,
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
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Completed',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
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
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.access_time,
                      label: '${workout.durationMinutes} min',
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.fitness_center,
                      label: '${workout.exercises.length} exercises',
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.trending_up,
                      label: workout.difficulty,
                      color: workout.category == 'Cardio' ? Colors.green : Colors.blue,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Completion info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed ${workout.totalSets} sets',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '100% Complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Progress bar (always full for completed workouts)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey.shade300,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.green.withOpacity(0.8)],
                        ),
                      ),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Completed Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout to see it here.\nYour achievements will be tracked automatically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              // Navigate to workouts screen
              Navigator.pop(context); // Go back to main navigation
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Start Your First Workout'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
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

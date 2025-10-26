import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Your app files (keep as you had them)
import '../providers/workout_provider.dart';
import '../providers/membership_provider.dart';
import '../screens/create_workout_screen.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/import_workout_screen.dart';
import '../utils/responsive.dart';

class WorkoutsScreen extends StatefulWidget {
  static const route = '/workouts';
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _category = 'All';
  String _difficulty = 'All';
  String _sortBy = 'Name';

  final List<String> _categories = const ['All', 'Cardio', 'Strength', 'Flexibility', 'HIIT'];
  final List<String> _difficulties = const ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _sortOptions = const ['Name', 'Duration', 'Difficulty', 'Progress'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lightweight fuzzy matcher: subsequence + contains
  bool _fuzzyMatch(String hay, String needle) {
    if (needle.isEmpty) return true;
    hay = hay.toLowerCase();
    needle = needle.toLowerCase();

    if (hay.contains(needle)) return true;

    // subsequence check (fuz/z/y -> fuzzy)
    int i = 0;
    for (final c in hay.characters) {
      if (i < needle.length && c == needle[i]) i++;
      if (i == needle.length) return true;
    }
    return false;
  }

  List<dynamic> _filtered(List<dynamic> input) {
    final items = input.toList();

    String n(dynamic w) => (w?.name ?? '').toString();
    String cat(dynamic w) => (w?.category ?? '').toString();
    String diff(dynamic w) => (w?.difficulty ?? '').toString();
    int dur(dynamic w) => (w?.durationMinutes is int) ? w.durationMinutes as int : int.tryParse('${w?.durationMinutes ?? 0}') ?? 0;
    num prog(dynamic w) => (w?.progress is num) ? w.progress as num : num.tryParse('${w?.progress ?? 0}') ?? 0;

    // Search (name | category | difficulty)
    var list = items.where((w) {
      if (_query.isEmpty) return true;
      final h1 = n(w);
      final h2 = cat(w);
      final h3 = diff(w);
      return _fuzzyMatch(h1, _query) || _fuzzyMatch(h2, _query) || _fuzzyMatch(h3, _query);
    }).toList();

    // Category filter
    if (_category != 'All') {
      list = list.where((w) => cat(w) == _category).toList();
    }

    // Difficulty filter
    if (_difficulty != 'All') {
      list = list.where((w) => diff(w) == _difficulty).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Name':
        list.sort((a, b) => n(a).compareTo(n(b)));
        break;
      case 'Duration':
        list.sort((a, b) => dur(b).compareTo(dur(a)));
        break;
      case 'Difficulty':
        const order = {'Beginner': 1, 'Intermediate': 2, 'Advanced': 3};
        int rank(dynamic w) => order[diff(w)] ?? 0;
        list.sort((a, b) => rank(a).compareTo(rank(b)));
        break;
      case 'Progress':
        list.sort((a, b) => prog(b).compareTo(prog(a)));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.getScreenPadding(context);

    // Watch the provider. If it's not provided yet, catch gracefully.
    List<dynamic> all = const [];
    try {
      final prov = context.watch<WorkoutProvider>();
      all = prov.workouts;
    } catch (_) {
      // Provider not found; keep empty list
    }

    // Filter out imported workouts (they should only appear in Imported tab)
    final nonImportedWorkouts = all.where((w) => !w.description.contains('Imported from web')).toList();
    final list = _filtered(nonImportedWorkouts);

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
                const Color(0xFF4E6CF8), // Vibrant Blue
                const Color(0xFF3ECF8E), // Fresh Green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4E6CF8).withOpacity(0.3),
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
                      const Color(0xFF4E6CF8), // Blue
                      const Color(0xFF3ECF8E), // Green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context) * 0.5),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: Responsive.getIconSize(context) * 0.7,
                ),
              ),
              SizedBox(width: Responsive.getSpacing(context) * 0.5),
              Text(
                'Workouts',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.getTitleFontSize(context),
                  color: Colors.white, // White for contrast
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          // Add right margin to the actions
          Padding(
            padding: EdgeInsets.only(right: Responsive.getSpacing(context)),
            child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isTablet = screenWidth > 600;
              
              if (isTablet) {
                // Tablet: Show both buttons with labels
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Import button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3ECF8E), // Green for import
                        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3ECF8E).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(ImportWorkoutScreen.route),
                        icon: Icon(Icons.web, size: Responsive.getIconSize(context) * 0.6),
                        label: Text(
                          'Import',
                          style: TextStyle(fontSize: Responsive.getBodyFontSize(context) * 0.8),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getSpacing(context) * 0.75,
                            vertical: Responsive.getSpacing(context) * 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.getSpacing(context) * 0.75),
                    // Create button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E6CF8), // Solid blue (no gradient)
                        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4E6CF8).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(CreateWorkoutScreen.route),
                        icon: Icon(Icons.add, size: Responsive.getIconSize(context) * 0.6),
                        label: Text(
                          'Create',
                          style: TextStyle(fontSize: Responsive.getBodyFontSize(context) * 0.8),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getSpacing(context) * 0.75,
                            vertical: Responsive.getSpacing(context) * 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Phone: Show icon-only buttons to save space
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Import button (icon only)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3ECF8E), // Green for import
                        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3ECF8E).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pushNamed(ImportWorkoutScreen.route),
                        icon: Icon(Icons.web, size: Responsive.getIconSize(context) * 0.7),
                        tooltip: 'Import Workout',
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(Responsive.getSpacing(context) * 0.5),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.getSpacing(context) * 0.5),
                    // Create button (icon only)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E6CF8), // Solid blue (no gradient)
                        borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4E6CF8).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pushNamed(CreateWorkoutScreen.route),
                        icon: Icon(Icons.add, size: Responsive.getIconSize(context) * 0.7),
                        tooltip: 'Create Workout',
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(Responsive.getSpacing(context) * 0.5),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
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
              const Color(0xFFB4E1FF), // Cool steel blue start
              const Color(0xFFE4EEFF), // Cool steel blue end
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
          // Search + Filters
          Padding(
            padding: pad,
            child: Column(
              children: [
                // Search field with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: Responsive.getBodyFontSize(context),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search workouts...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                        size: Responsive.getIconSize(context) * 0.8,
                      ),
                      hintMaxLines: 1,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSpacing(context) * 2.5,
                        vertical: Responsive.getSpacing(context) * 2,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(height: 12),
                // Filters row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterDropdown(
                        label: 'Category',
                        value: _category,
                        options: _categories,
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(width: 8),
                      _FilterDropdown(
                        label: 'Difficulty',
                        value: _difficulty,
                        options: _difficulties,
                        onChanged: (v) => setState(() => _difficulty = v),
                      ),
                      const SizedBox(width: 8),
                      _FilterDropdown(
                        label: 'Sort',
                        value: _sortBy,
                        options: _sortOptions,
                        onChanged: (v) => setState(() => _sortBy = v),
                      ),
                      if (_query.isNotEmpty || _category != 'All' || _difficulty != 'All')
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _query = '';
                                _category = 'All';
                                _difficulty = 'All';
                                _sortBy = 'Name';
                              });
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Membership status indicator
          Consumer<MembershipProvider>(
            builder: (context, membershipProvider, child) {
              final isPremium = membershipProvider.isPremium;
              final maxWorkouts = membershipProvider.getMaxWorkouts();
              final currentWorkouts = list.length;
              
              if (isPremium) return const SizedBox.shrink();
              
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  pad.left, 
                  pad.top * 0.5, 
                  pad.right, 
                  pad.bottom * 0.5,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B7280).withOpacity(0.1),
                        const Color(0xFF9CA3AF).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6B7280).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF6B7280),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Basic Plan: $currentWorkouts/$maxWorkouts workouts used',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/settings'),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Results meta
          Padding(
            padding: EdgeInsets.only(left: (pad.left), right: (pad.right), bottom: 8),
            child: Row(
              children: [
                Text(
                  '${list.length} workout${list.length == 1 ? '' : 's'} found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.8),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // List
          if (list.isEmpty)
            _EmptyState(
              hasFilters: _query.isNotEmpty || _category != 'All' || _difficulty != 'All',
              onClear: () {
                setState(() {
                  _query = '';
                  _category = 'All';
                  _difficulty = 'All';
                  _sortBy = 'Name';
                });
                _searchController.clear();
              },
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad.left, vertical: 8),
              child: Column(
                children: list
                    .map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkoutCard(workout: w),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(
                      '$label: $o',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final dynamic workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final name = (workout?.name ?? 'Workout').toString();
    final category = (workout?.category ?? 'General').toString();
    final difficulty = (workout?.difficulty ?? 'Beginner').toString();
    final duration = (workout?.durationMinutes is int)
        ? workout.durationMinutes as int
        : int.tryParse('${workout?.durationMinutes ?? 0}') ?? 0;

    final completed = (workout?.exercises is List) ? (workout.exercises as List).length : (workout?.completedExercises ?? 0) as int? ?? 0;
    final total = (workout?.totalExercises ?? (workout?.exercises is List ? (workout.exercises as List).length : 0)) as int? ?? 0;

    // Category-specific colors for workout types
    Color getCategoryColor() {
      switch (category) {
        case 'Cardio':
          return const Color(0xFF3ECF8E); // Green
        case 'Strength':
          return const Color(0xFFE91E63); // Pink/Red
        case 'Flexibility':
          return const Color(0xFF4E6CF8); // Blue
        case 'HIIT':
          return const Color(0xFFFF5722); // Orange
        default:
          return const Color(0xFF4E6CF8); // Blue
      }
    }

    final primary = getCategoryColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(Responsive.getCardBorderRadius(context)),
        border: Border.all(
          color: primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Subtle drop shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.getCardBorderRadius(context)),
          onTap: () {
            final id = workout?.id ?? workout.hashCode;
            Navigator.of(context).pushNamed(WorkoutDetailScreen.route, arguments: id);
          },
          onLongPress: () => _showDeleteDialog(context, workout),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading icon with gradient
                Container(
                  padding: EdgeInsets.all(Responsive.getSpacing(context) * 1.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                    size: Responsive.getIconSize(context),
                  ),
                ),
                const SizedBox(width: 12),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: Responsive.getSubtitleFontSize(context),
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _pill(context, category, primary),
                          _pill(
                            context,
                            difficulty,
                            difficulty == 'Beginner'
                                ? const Color(0xFF4CAF50) // Green
                                : difficulty == 'Intermediate'
                                    ? const Color(0xFFFF9800) // Orange
                                    : const Color(0xFFE91E63), // Pink/Red for Advanced
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: primary),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed/$total exercises',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: primary.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic workout) {
    final workoutName = (workout?.name ?? 'Workout').toString();
    final workoutId = workout?.id ?? workout.hashCode.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "$workoutName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final prov = context.read<WorkoutProvider>();
              await prov.deleteWorkout(workoutId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "$workoutName"')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cardio':
        return Icons.directions_run;
      case 'Strength':
        return Icons.fitness_center;
      case 'Flexibility':
        return Icons.self_improvement;
      case 'HIIT':
        return Icons.local_fire_department;
      default:
        return Icons.sports_gymnastics;
    }
  }

  Widget _pill(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;
  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hasFilters ? Icons.search_off : Icons.fitness_center_outlined, size: 64, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'No workouts found' : 'No workouts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters ? 'Try adjusting your filters or search terms' : 'Create your first workout to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            FilledButton.icon(onPressed: onClear, icon: const Icon(Icons.clear_all), label: const Text('Clear Filters'))
          else
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(CreateWorkoutScreen.route),
              icon: const Icon(Icons.add),
              label: const Text('Create Workout'),
            ),
        ],
      ),
    );
  }
}

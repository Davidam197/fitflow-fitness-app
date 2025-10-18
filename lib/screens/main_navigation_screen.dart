import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workouts_screen.dart';
import 'active_workouts_screen.dart';
import 'settings_screen.dart';
import '../navigation/navigation_controller.dart';
import '../utils/responsive.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutsScreen(),
    const ActiveWorkoutsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NavigationController.currentIndexNotifier.addListener(_onIndexChanged);
  }

  @override
  void dispose() {
    NavigationController.currentIndexNotifier.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _onIndexChanged() {
    setState(() {});
  }

  NavigationDestination _buildNavDestination(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required Color color,
    Color? secondaryColor,
  }) {
    final gradientColor = secondaryColor ?? color;

    return NavigationDestination(
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        size: Responsive.getIconSize(context),
      ),
      selectedIcon: Container(
        padding: EdgeInsets.all(Responsive.getSpacing(context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              gradientColor.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.getBorderRadius(context)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(selectedIcon, color: Colors.white, size: Responsive.getIconSize(context)),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: NavigationController.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.98),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: ClipRect(
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: NavigationController.currentIndex,
            onDestinationSelected: (index) {
              NavigationController.setIndex(index);
            },
            indicatorColor: Colors.transparent,
            destinations: [
              _buildNavDestination(
                context,
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                color: const Color(0xFF3E6CF6), // Blue
              ),
              _buildNavDestination(
                context,
                index: 1,
                icon: Icons.fitness_center_outlined,
                selectedIcon: Icons.fitness_center,
                label: 'Workouts',
                color: const Color(0xFF4E6CF8), // Blue
              ),
              _buildNavDestination(
                context,
                index: 2,
                icon: Icons.play_circle_outline,
                selectedIcon: Icons.play_circle,
                label: 'Active',
                color: const Color(0xFF20C38B), // Green
              ),
              _buildNavDestination(
                context,
                index: 3,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                color: const Color(0xFFFFA733), // Orange
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local settings state (replace with your persistence as needed)
  bool notifications = true;
  int reminderHour = 9;
  bool sounds = true;
  bool haptics = true;
  bool autoStart = false;
  bool progressAnims = true;
  String units = 'Metric (kg, cm)';
  String language = 'English';
  ThemeMode themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 0, // Remove the entire app bar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF), // Soft gradient base
              Color(0xFFE9F1FF), // Subtle turquoise tint
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Responsive.getSpacing(context),
            Responsive.getSpacing(context) * 1.5, // Top padding
            Responsive.getSpacing(context),
            0,
          ),
          children: [
              _sectionTitle(context, 'Profile'),
            _ProfileCard(
              onEdit: () {
                // TODO: open edit profile
                _snack(context, 'Edit profile tapped');
              },
            ),
              const SizedBox(height: 24),

              _sectionTitle(context, 'App Preferences'),
            _Tile(
              icon: Icons.dark_mode_outlined,
              title: 'Theme',
              subtitle: _themeDesc(themeMode),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTheme(context),
            ),
            _Tile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: language,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickFromList(
                context: context,
                title: 'Select Language',
                options: const ['English', 'Spanish', 'French', 'German', 'Italian'],
                current: language,
                onPick: (v) => setState(() => language = v),
              ),
            ),
            _Tile(
              icon: Icons.straighten_outlined,
              title: 'Units',
              subtitle: units,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickFromList(
                context: context,
                title: 'Select Units',
                options: const ['Metric (kg, cm)', 'Imperial (lbs, ft)'],
                current: units,
                onPick: (v) => setState(() => units = v),
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Notifications'),
            _Tile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive workout reminders and updates',
              trailing: Switch(value: notifications, onChanged: (v) => setState(() => notifications = v)),
            ),
            _Tile(
              icon: Icons.schedule_outlined,
              title: 'Workout Reminder',
              subtitle: 'Daily at ${_fmtHour(reminderHour)}',
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: reminderHour, minute: 0));
                if (picked != null) setState(() => reminderHour = picked.hour);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Workout'),
            _Tile(
              icon: Icons.volume_up_outlined,
              title: 'Sound Effects',
              subtitle: 'Play sounds during workouts',
              trailing: Switch(value: sounds, onChanged: (v) => setState(() => sounds = v)),
            ),
            _Tile(
              icon: Icons.vibration_outlined,
              title: 'Haptic Feedback',
              subtitle: 'Vibrate on interactions',
              trailing: Switch(value: haptics, onChanged: (v) => setState(() => haptics = v)),
            ),
            _Tile(
              icon: Icons.play_circle_outline,
              title: 'Auto-start Workouts',
              subtitle: 'Automatically start first exercise',
              trailing: Switch(value: autoStart, onChanged: (v) => setState(() => autoStart = v)),
            ),
            _Tile(
              icon: Icons.animation_outlined,
              title: 'Progress Animations',
              subtitle: 'Show animated progress indicators',
              trailing: Switch(value: progressAnims, onChanged: (v) => setState(() => progressAnims = v)),
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Data & Storage'),
            _Tile(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your workout data',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _snack(context, 'Export coming soon'),
            ),
            _Tile(
              icon: Icons.upload_outlined,
              title: 'Import Data',
              subtitle: 'Import workout data from file',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _snack(context, 'Import coming soon'),
            ),
            _Tile(
              icon: Icons.delete_outline,
              title: 'Clear All Data',
              subtitle: 'Remove all workouts and settings',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmClear(context),
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'About'),
            _Tile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'FitFlow',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.fitness_center, size: 48),
                children: const [Text('Your personal fitness companion.')],
              ),
            ),
            _Tile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Help & Support'),
                  content: const Text('Email: support@fitflow.app\nLive Chat: 24/7'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              ),
            ),
            _Tile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Your data stays on your device. We do not collect or share your personal info.\n\n'
                      'Stored locally:\n• Workout history\n• Preferences\n• Settings',
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _themeDesc(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        return 'System (${isDark ? "Dark" : "Light"})';
    }
  }

  Future<void> _pickTheme(BuildContext context) async {
    ThemeMode picked = themeMode;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Theme'),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                  title: const Text('System'),
                value: ThemeMode.system,
                groupValue: picked,
                onChanged: (v) => setLocal(() => picked = v ?? ThemeMode.system),
              ),
              RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: picked,
                onChanged: (v) => setLocal(() => picked = v ?? ThemeMode.light),
              ),
              RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: picked,
                onChanged: (v) => setLocal(() => picked = v ?? ThemeMode.dark),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => themeMode = picked);

              // If you have a ThemeProvider, call it here:
              // context.read<ThemeProvider>().setThemeMode(
              //   picked == ThemeMode.light ? AppThemeMode.light :
              //   picked == ThemeMode.dark  ? AppThemeMode.dark  : AppThemeMode.system
              // );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromList({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onPick,
  }) async {
    String picked = current;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => RadioListTile<String>(
                        title: Text(o),
                      value: o,
                      groupValue: picked,
                      onChanged: (v) => setLocal(() => picked = v ?? current),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onPick(picked);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all workouts and settings. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement your clearing logic (db, boxes, prefs)
              _snack(context, 'All data cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _fmtHour(int h) {
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:00 $ampm';
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.1),
                        cs.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: cs.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                        const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;
  const _ProfileCard({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00B0FF), // Turquoise
            Color(0xFF4E6CF8), // Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B0FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF4E6CF8).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                        const SizedBox(height: 4),
                      Text(
                        'Fitness Enthusiast',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, Responsive.getSpacing(context) * 1.5, 0, Responsive.getSpacing(context) * 0.75),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF00B0FF), // Turquoise
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        SizedBox(width: Responsive.getSpacing(context) * 0.5),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.getSubtitleFontSize(context),
            color: const Color(0xFF0E1625), // Dark navy
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

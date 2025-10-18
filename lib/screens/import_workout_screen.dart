import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/web_scraping_service.dart';

class ImportWorkoutScreen extends StatefulWidget {
  static const route = '/import-workout';

  const ImportWorkoutScreen({super.key});

  @override
  State<ImportWorkoutScreen> createState() => _ImportWorkoutScreenState();
}

class _ImportWorkoutScreenState extends State<ImportWorkoutScreen> {
  final TextEditingController _urlCtrl = TextEditingController(
    text:
        'https://www.muscleandfitness.com/routine/workouts/workout-routines/chris-hemsworths-god-thor-workout/',
  );
  bool _importing = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final prov = context.read<WorkoutProvider>();
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a workout URL')),
      );
      return;
    }

    setState(() => _importing = true);
    try {
      final count = await WebScrapingService.importAndSave(
        provider: prov,
        url: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $count workout(s)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Workout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // URL input + button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'Paste workout page URL (e.g., Muscle & Fitness)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _importing ? null : _import,
                    icon: const Icon(Icons.cloud_download),
                    label: Text(_importing ? 'Importing…' : 'Import'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Existing workouts list (so you can see results immediately)
          if (workouts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No workouts yet.\nPaste a URL above to import a plan.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...workouts.map(
              (w) => Card(
                child: ListTile(
                  title: Text(w.name),
                  subtitle: Text('${w.category} • ${w.exercises.length} exercise(s)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: navigate to your workout detail screen if you have one
                    // Navigator.pushNamed(context, WorkoutDetailScreen.route, arguments: w.id);
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

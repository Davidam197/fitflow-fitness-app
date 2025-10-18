import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../models/workout.dart';
import '../models/exercise.dart';

class WebScrapingService {
  // Patterns for identifying workout days/sessions
  static final List<RegExp> dayPatterns = [
    RegExp(r'day\s*\d+', caseSensitive: false),
    RegExp(r'workout\s*\d+', caseSensitive: false),
    RegExp(r'session\s*\d+', caseSensitive: false),
    RegExp(r'(monday|tuesday|wednesday|thursday|friday|saturday|sunday)',
        caseSensitive: false),
    RegExp(
        r'(chest|back|legs|arms|shoulders|push|pull|upper|lower|full\s*body)',
        caseSensitive: false),
    RegExp(r'week\s*\d+', caseSensitive: false),
  ];

  // Pattern for sets x reps
  static final RegExp setsRepsPattern =
      RegExp(r'(\d+)\s*(?:x|×|sets?\s*(?:of|x)?)\s*(\d+)(?:\s*reps?)?',
          caseSensitive: false);

  /// Scrapes workout data from a given URL
  static Future<List<Workout>> scrapeWorkout(String url) async {
    try {
      // Validate URL
      if (!_isValidUrl(url)) {
        throw Exception('Invalid URL format');
      }

      // Fetch the webpage
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      // Parse HTML
      final document = html_parser.parse(response.body);

      // Remove unwanted elements
      _removeUnwantedElements(document);

      // Extract workouts
      return _extractWorkouts(document);
    } catch (e) {
      throw Exception('Failed to scrape workout: $e');
    }
  }

  /// Validates if the URL is properly formatted
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static void _removeUnwantedElements(dom.Document document) {
    final unwantedSelectors = [
      'script',
      'style',
      'nav',
      'footer',
      'header',
      '.ad',
      '.advertisement'
    ];

    for (final selector in unwantedSelectors) {
      document.querySelectorAll(selector).forEach((el) => el.remove());
    }
  }

  static List<Workout> _extractWorkouts(dom.Document document) {
    final workouts = <Workout>[];
    Workout? currentWorkout;

    // Get all elements that might contain workout info
    final elements = document.querySelectorAll(
        'h1, h2, h3, h4, h5, h6, p, li, td, th, div, strong, b');

    for (final element in elements) {
      final text = element.text.trim();

      if (text.isEmpty || text.length < 3) continue;

      // Check if this is a workout header
      final isWorkoutHeader =
          WebScrapingService._isWorkoutHeader(text) && text.length < 100;

      if (isWorkoutHeader) {
        // Save previous workout if it has exercises
        if (currentWorkout != null && currentWorkout.exercises.isNotEmpty) {
          workouts.add(currentWorkout);
        }

        // Start new workout
        currentWorkout = Workout(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: text,
          category: _determineCategory(document, text),
          description: 'Imported from web',
          durationMinutes: 30,
          difficulty: 'Intermediate',
          exercises: [],
        );
      } else if (currentWorkout != null) {
        // Try to extract exercise
        final exercise = WebScrapingService._parseExercise(text);
        if (exercise != null) {
          currentWorkout.exercises.add(exercise);
        }
      } else {
        // No workout header found yet, but found an exercise
        final exercise = WebScrapingService._parseExercise(text);
        if (exercise != null) {
          currentWorkout ??= Workout(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Workout',
            category: 'Strength',
            description: 'Imported from web',
            durationMinutes: 30,
            difficulty: 'Intermediate',
            exercises: [],
          );
          currentWorkout.exercises.add(exercise);
        }
      }
    }

    // Add the last workout
    if (currentWorkout != null && currentWorkout.exercises.isNotEmpty) {
      workouts.add(currentWorkout);
    }

    return workouts;
  }

  static bool _isWorkoutHeader(String text) {
    return dayPatterns.any((pattern) => pattern.hasMatch(text));
  }

  static Exercise? _parseExercise(String text) {
    // Skip if too short or too long
    if (text.length < 5 || text.length > 200) return null;

    // Look for sets x reps pattern
    final match = setsRepsPattern.firstMatch(text);

    if (match != null) {
      // Extract exercise name (text before sets/reps)
      var exerciseName = text.substring(0, match.start).trim();

      // Clean up common prefixes/bullets
      exerciseName = exerciseName.replaceAll(RegExp(r'^[\d\.\-\*•:\s]+'), '').trim();

      // Skip if no valid name
      if (exerciseName.length < 3) return null;

      // Extract notes (text after sets/reps)
      final notes = text.substring(match.end).trim();

      return Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: exerciseName,
        sets: int.parse(match.group(1)!),
        reps: int.parse(match.group(2)!),
        durationSeconds: 60,
        equipment: '',
        notes: notes.isEmpty ? '' : notes,
        description: '',
      );
    }

    return null;
  }

  /// Determines workout category based on content
  static String _determineCategory(dom.Document document, String title) {
    final content = (document.body?.text ?? '').toLowerCase();
    final titleLower = title.toLowerCase();

    if (content.contains('cardio') || titleLower.contains('cardio') || 
        content.contains('running') || content.contains('cycling')) {
      return 'Cardio';
    }
    
    if (content.contains('strength') || titleLower.contains('strength') ||
        content.contains('weight') || content.contains('muscle')) {
      return 'Strength';
    }
    
    if (content.contains('flexibility') || content.contains('yoga') ||
        content.contains('stretch') || titleLower.contains('flexibility')) {
      return 'Flexibility';
    }
    
    if (content.contains('hiit') || content.contains('high intensity') ||
        titleLower.contains('hiit')) {
      return 'HIIT';
    }

    return 'Strength'; // Default
  }

  /// Gets a list of supported websites
  static List<String> getSupportedWebsites() {
    return [
      'Any website with workout content',
      'Bodybuilding.com',
      'Muscle & Strength',
      'Fitness Blender',
      'Nike Training Club',
      'Generic workout pages',
    ];
  }
}

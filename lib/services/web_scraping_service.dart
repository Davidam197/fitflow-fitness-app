import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../models/workout.dart';
import '../models/exercise.dart';

class WebScrapingService {
  // CORS proxies to try in order
  static final List<String> corsProxies = [
    'https://api.allorigins.win/raw?url=',
    'https://corsproxy.io/?',
    'https://api.codetabs.com/v1/proxy?quest=',
  ];

  // Enhanced patterns for identifying workout days/sessions
  static final List<RegExp> dayPatterns = [
    RegExp(r'\bday\s*\d+\b', caseSensitive: false),
    RegExp(r'\bworkout\s*[A-Z]?\d*\b', caseSensitive: false),
    RegExp(r'\bsession\s*\d+\b', caseSensitive: false),
    RegExp(r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
        caseSensitive: false),
    RegExp(
        r'\b(chest|back|legs?|arms?|shoulders?|biceps?|triceps?|delts?|quads?|hamstrings?|glutes?|calves?)\b',
        caseSensitive: false),
    RegExp(r'\b(push|pull|upper|lower|full\s*body)\b', caseSensitive: false),
    RegExp(r'\bweek\s*\d+\b', caseSensitive: false),
    RegExp(r'\bphase\s*\d+\b', caseSensitive: false),
    RegExp(r'\b(strength|power|hypertrophy|endurance|conditioning)\b',
        caseSensitive: false),
    RegExp(r'\bworkout:\s*', caseSensitive: false),
  ];

  // Multiple patterns for sets x reps (more comprehensive)
  static final List<RegExp> setsRepsPatterns = [
    // Standard formats
    RegExp(r'(\d+)\s*(?:x|×|X)\s*(\d+)(?:\s*(?:reps?|repetitions?))?',
        caseSensitive: false),
    RegExp(r'(\d+)\s*sets?\s*(?:of|x|×|,)?\s*(\d+)(?:\s*reps?)?',
        caseSensitive: false),
    // Reversed format
    RegExp(r'(\d+)\s*reps?\s*(?:x|×|,)\s*(\d+)\s*sets?', caseSensitive: false),
    // With explicit labels
    RegExp(r'sets?:\s*(\d+).*?reps?:\s*(\d+)', caseSensitive: false),
    RegExp(r'(\d+)\s*set\(s\)\s*(?:of|x)?\s*(\d+)', caseSensitive: false),
  ];

  /// Scrapes workout data from a given URL
  static Future<List<Workout>> scrapeWorkout(String url) async {
    Exception? lastError;

    // Try with CORS proxies
    for (final proxy in corsProxies) {
      try {
        final response = await http.get(
          Uri.parse('$proxy${Uri.encodeComponent(url)}'),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return _processHtml(response.body);
        }
      } catch (e) {
        lastError = Exception('Proxy $proxy failed: $e');
        continue;
      }
    }

    // Try direct request as last resort
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _processHtml(response.body);
      }
    } catch (e) {
      lastError = Exception('Direct request failed: $e');
    }

    throw lastError ?? Exception('Failed to fetch page');
  }

  static List<Workout> _processHtml(String html) {
    // Parse HTML
    final document = html_parser.parse(html);

    // Remove unwanted elements
    _removeUnwantedElements(document);

    // Try multiple extraction methods
    List<Workout> workouts = [];

    // Method 1: Standard hierarchical extraction
    workouts = _extractWorkouts(document);

    // Method 2: If no workouts found, try table-based extraction
    if (workouts.isEmpty) {
      workouts = _extractFromTables(document);
    }

    // Method 3: If still no workouts, try list-based extraction
    if (workouts.isEmpty) {
      workouts = _extractFromLists(document);
    }

    // Method 4: Try extracting from specific article/content containers
    if (workouts.isEmpty) {
      workouts = _extractFromArticleContent(document);
    }

    // Method 5: Last resort - just find all exercises
    if (workouts.isEmpty) {
      workouts = _extractAllExercises(document);
    }

    return workouts;
  }

  static void _removeUnwantedElements(dom.Document document) {
    final unwantedSelectors = [
      'script',
      'style',
      'nav',
      'footer',
      'header',
      '.ad',
      '.advertisement',
      '.social',
      '.comments',
      'iframe',
      '.cookie',
      '.popup',
      '.modal',
    ];

    for (final selector in unwantedSelectors) {
      document.querySelectorAll(selector).forEach((el) => el.remove());
    }
  }

  static List<Workout> _extractWorkouts(dom.Document document) {
    final workouts = <Workout>[];
    Workout? currentWorkout;

    // Focus on main content areas
    final contentSelectors = [
      'article',
      '.content',
      '.post',
      '.entry',
      'main',
      '#content',
      '.workout',
      'body'
    ];

    dom.Element? contentArea;
    for (final selector in contentSelectors) {
      contentArea = document.querySelector(selector);
      if (contentArea != null) break;
    }

    final searchArea = contentArea ?? document.body;
    if (searchArea == null) return [];

    // Get all elements that might contain workout info
    final elements = searchArea.querySelectorAll(
        'h1, h2, h3, h4, h5, h6, p, li, td, th, div, strong, b, span');

    for (final element in elements) {
      final text = element.text.trim();

      if (text.isEmpty || text.length < 3) continue;

      // Check if this is a workout header
      final isWorkoutHeader = _isWorkoutHeader(text) && text.length < 200;

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
      } else {
        // Try to extract exercise
        final exercise = _parseExercise(text);
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

  static List<Workout> _extractFromArticleContent(dom.Document document) {
    final workouts = <Workout>[];
    
    // Look for specific workout content patterns
    final contentSelectors = [
      'article',
      '.post-content',
      '.entry-content',
      '.article-content',
      'main',
    ];

    for (final selector in contentSelectors) {
      final article = document.querySelector(selector);
      if (article == null) continue;

      final paragraphs = article.querySelectorAll('p, div, li');
      Workout? currentWorkout;

      for (final p in paragraphs) {
        final text = p.text.trim();
        if (text.isEmpty || text.length < 5) continue;

        // Check for workout header
        if (_isWorkoutHeader(text) && text.length < 200) {
          if (currentWorkout != null && currentWorkout.exercises.isNotEmpty) {
            workouts.add(currentWorkout);
          }
          currentWorkout = Workout(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: text,
            category: _determineCategory(document, text),
            description: 'Imported from web',
            durationMinutes: 30,
            difficulty: 'Intermediate',
            exercises: [],
          );
        } else {
          final exercise = _parseExercise(text);
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

      if (currentWorkout != null && currentWorkout.exercises.isNotEmpty) {
        workouts.add(currentWorkout);
      }

      if (workouts.isNotEmpty) break;
    }

    return workouts;
  }

  static List<Workout> _extractFromTables(dom.Document document) {
    final workouts = <Workout>[];
    final tables = document.querySelectorAll('table');

    for (var i = 0; i < tables.length; i++) {
      final table = tables[i];
      final exercises = <Exercise>[];

      // Check table rows
      final rows = table.querySelectorAll('tr');

      for (final row in rows) {
        final cells = row.querySelectorAll('td, th');
        if (cells.isEmpty) continue;

        final rowText = cells.map((c) => c.text.trim()).join(' ');
        final exercise = _parseExercise(rowText);

        if (exercise != null) {
          exercises.add(exercise);
        }
      }

      if (exercises.isNotEmpty) {
        // Look for a heading before the table
        var workoutName = 'Workout ${i + 1}';
        var prevElement = table.previousElementSibling;

        int searchDepth = 0;
        while (prevElement != null && searchDepth < 5) {
          if (prevElement.localName?.contains('h') == true) {
            final headerText = prevElement.text.trim();
            if (headerText.length < 200 && headerText.isNotEmpty) {
              workoutName = headerText;
              break;
            }
          }
          prevElement = prevElement.previousElementSibling;
          searchDepth++;
        }

        workouts.add(Workout(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: workoutName,
          category: _determineCategory(document, workoutName),
          description: 'Imported from web',
          durationMinutes: 30,
          difficulty: 'Intermediate',
          exercises: exercises,
        ));
      }
    }

    return workouts;
  }

  static List<Workout> _extractFromLists(dom.Document document) {
    final workouts = <Workout>[];
    final lists = document.querySelectorAll('ul, ol');

    for (var i = 0; i < lists.length; i++) {
      final list = lists[i];
      final exercises = <Exercise>[];

      final items = list.querySelectorAll('li');

      for (final item in items) {
        final text = item.text.trim();
        final exercise = _parseExercise(text);

        if (exercise != null) {
          exercises.add(exercise);
        }
      }

      // Only consider lists with at least 2 exercises
      if (exercises.length >= 2) {
        // Look for a heading before the list
        var workoutName = 'Workout ${workouts.length + 1}';
        var prevElement = list.previousElementSibling;

        int searchDepth = 0;
        while (prevElement != null && searchDepth < 5) {
          if (prevElement.localName?.contains('h') == true) {
            final headerText = prevElement.text.trim();
            if (headerText.length < 200 && headerText.isNotEmpty) {
              workoutName = headerText;
              break;
            }
          }
          prevElement = prevElement.previousElementSibling;
          searchDepth++;
        }

        workouts.add(Workout(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: workoutName,
          category: _determineCategory(document, workoutName),
          description: 'Imported from web',
          durationMinutes: 30,
          difficulty: 'Intermediate',
          exercises: exercises,
        ));
      }
    }

    return workouts;
  }

  static List<Workout> _extractAllExercises(dom.Document document) {
    final exercises = <Exercise>[];

    // Get all text elements
    final elements = document.querySelectorAll('p, li, div, td, span');

    for (final element in elements) {
      final text = element.text.trim();
      final exercise = _parseExercise(text);

      if (exercise != null) {
        exercises.add(exercise);
      }
    }

    if (exercises.isEmpty) return [];

    return [Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Imported Workout',
      category: 'Strength',
      description: 'Imported from web',
      durationMinutes: 30,
      difficulty: 'Intermediate',
      exercises: exercises,
    )];
  }

  static bool _isWorkoutHeader(String text) {
    // Must contain a day pattern
    final hasPattern = dayPatterns.any((pattern) => pattern.hasMatch(text));

    // Should not contain sets/reps info (that's an exercise, not a header)
    final hasExerciseInfo = setsRepsPatterns.any((p) => p.hasMatch(text));

    // Additional check: headers are usually shorter
    final isReasonableLength = text.length < 200;

    return hasPattern && !hasExerciseInfo && isReasonableLength;
  }

  static Exercise? _parseExercise(String text) {
    // Skip if too short or too long
    if (text.length < 5 || text.length > 300) return null;

    // Skip common non-exercise text
    final skipWords = [
      'click',
      'read more',
      'share',
      'advertisement',
      'subscribe',
      'comment',
      'follow',
      'copyright',
      'related',
      'trending',
      'popular',
    ];
    
    final lowerText = text.toLowerCase();
    if (skipWords.any((word) => lowerText.contains(word))) {
      return null;
    }

    // Skip if it looks like a navigation or UI element
    if (text.split(' ').length < 2) return null;

    // Try each pattern
    for (final pattern in setsRepsPatterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        // Extract exercise name (text before sets/reps)
        var exerciseName = text.substring(0, match.start).trim();

        // Clean up common prefixes/bullets
        exerciseName = exerciseName
            .replaceAll(RegExp(r'^[\d\.\-\*•:\s\)\]]+'), '')
            .replaceAll(RegExp(r'^\W+'), '')
            .trim();

        // Remove trailing colons or dashes
        exerciseName = exerciseName.replaceAll(RegExp(r'[:\-–—]+$'), '').trim();

        // Skip if no valid name or name is just numbers
        if (exerciseName.length < 3 || RegExp(r'^\d+$').hasMatch(exerciseName)) {
          continue;
        }

        // Extract notes (text after sets/reps)
        final notes = text.substring(match.end).trim();

        // Parse sets and reps (handle both orders)
        int sets, reps;
        if (text.toLowerCase().contains('reps') &&
            text.toLowerCase().indexOf('reps') < match.start) {
          // "10 reps x 3 sets" format
          reps = int.parse(match.group(1)!);
          sets = int.parse(match.group(2)!);
        } else {
          // "3 sets x 10 reps" format (most common)
          sets = int.parse(match.group(1)!);
          reps = int.parse(match.group(2)!);
        }

        // Sanity check: sets and reps should be reasonable numbers
        if (sets < 1 || sets > 20 || reps < 1 || reps > 100) {
          continue;
        }

        return Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: exerciseName,
          sets: sets,
          reps: reps,
          durationSeconds: 60,
          equipment: '',
          notes: notes.isEmpty ? '' : notes,
          description: '',
        );
      }
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
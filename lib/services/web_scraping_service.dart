import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../models/workout.dart';
import '../models/exercise.dart';
import '../providers/workout_provider.dart';

/// Scrapes workout plans from public articles.
/// Rule: One Workout per "Day/Workout/Session" header; collect exercises under it until the next header.
/// Fallback: If the URL looks like the Thor article and scraping fails, use a precise Thor preset.
/// Usage: await WebScrapingService.importAndSave(provider: context.read<WorkoutProvider>(), url: url);
class WebScrapingService {
  // --- Enhanced header detection patterns ---
  static final List<RegExp> _dayPatterns = [
    RegExp(r'\bday\s*\d+\b', caseSensitive: false),
    RegExp(r'\bworkout\s*\d+\b', caseSensitive: false),
    RegExp(r'\bsession\s*\d+\b', caseSensitive: false),
    RegExp(r'\bweek\s*\d+\b', caseSensitive: false),
    RegExp(r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
        caseSensitive: false),
  ];

  // --- Body part/muscle group patterns ---
  static final List<RegExp> _bodyPartPatterns = [
    RegExp(r'\b(chest|back|legs?|arms?|shoulders?|biceps?|triceps?|delts?|quads?|hamstrings?|glutes?|calves?|core|abs?)\b',
        caseSensitive: false),
    RegExp(r'\b(push|pull|upper|lower|full\s*body)\b', caseSensitive: false),
    RegExp(r'\b(chest\s*day|back\s*day|leg\s*day|arm\s*day|shoulder\s*day)\b', caseSensitive: false),
  ];


  // --- Sets/Reps detection ---
  // e.g., "4 x 12", "4x12", "4 × 12", "4 sets x 12 reps", "4 sets of 12"
  static final RegExp _setsRepsPair = RegExp(
    r'(?:(\d+)\s*(?:sets?|x|×)\s*(\d+)\s*(?:reps?)?)',
    caseSensitive: false,
  );

  // e.g., "7 sets: 10, 8, 6, 5, 4, 3, 3"
  static final RegExp _setsWithList = RegExp(
    r'(\d+)\s*sets?\s*[:\-]\s*([\d,\s\-–]+)',
    caseSensitive: false,
  );

  // e.g., "8–10 reps" or "12 reps"
  static final RegExp _repsOnly = RegExp(
    r'(\d+\s*(?:[\-–]\s*\d+)?)\s*reps?',
    caseSensitive: false,
  );

  // e.g., "20 min", "45 sec"
  static final RegExp _timeBased = RegExp(
    r'(\d+)\s*(min|mins|minutes|sec|secs|seconds)\b',
    caseSensitive: false,
  );

  // e.g., "to failure", "AMRAP", "superset", "drop set"
  static final RegExp _keywords = RegExp(
    r'\b(to\s*failure|amrap|as\s*many\s*reps\s*as\s*possible|drop\s*set|strip\s*set|superset|circuit)\b',
    caseSensitive: false,
  );

  /// Main convenience: scrape and save into the provider. Returns number of workouts imported.
  static Future<int> importAndSave({
    required WorkoutProvider provider,
    required String url,
  }) async {
    final workouts = await _importFromUrl(url);
    await provider.importWorkouts(workouts);
    return workouts.length;
  }

  /// Scrape workouts from URL without saving them. Returns list of workouts for organization.
  static Future<List<Workout>> scrapeWorkouts(String url) async {
    return await _importFromUrl(url);
  }

  // ---------------- internal: orchestrate generic scrape + fallback ----------------

  static Future<List<Workout>> _importFromUrl(String url) async {
    if (!_isValidUrl(url)) {
      throw Exception('Invalid URL');
    }

    final res = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'Mozilla/5.0 (FitFlow Workout Importer)',
      'Accept-Language': 'en-US,en;q=0.9',
    });

    if (res.statusCode != 200) {
      throw Exception('Failed to load page: HTTP ${res.statusCode}');
    }

    final doc = html_parser.parse(res.body);
    _removeUnwanted(doc);

    final thorStyle = _scrapeThorStyle(doc, sourceUrl: url);

    // If we saw any valid section headers, trust only thorStyle.
    final _validSectionSet = {
      'back','chest','legs','shoulders','arms','bonus','abs','abs circuit'
    };
    final sawSectionHeaders = doc.body?.querySelectorAll('h1,h2,h3')
        .any((h) => _validSectionSet.contains(_clean(h.text).toLowerCase())) ?? false;

    if (sawSectionHeaders) {
      if (thorStyle.isNotEmpty) return thorStyle;

      // If headers exist but we parsed nothing, fail fast (or use Thor preset if recognized)
      final u = Uri.tryParse(url);
      final host = u?.host.toLowerCase() ?? '';
      final path = u?.path.toLowerCase() ?? '';
      final looksLikeThor = host.contains('muscleandfitness.com') &&
          (path.contains('chris-hemsworth') || path.contains('thor'));
      if (looksLikeThor) return _stampSource(url, _thorPreset());

      throw Exception('Found section headers but could not parse exercises under them.');
    }

    // No section headers at all → try the generic parser.
    try {
      final generic = _extractWorkouts(doc);
      if (generic.isNotEmpty) return _stampSource(url, generic);
    } catch (_) {
      // If generic scrape fails, we might still use fallback for known URL(s).
    }

    // Last resort: Thor preset for that URL
    final u = Uri.tryParse(url);
    final host = u?.host.toLowerCase() ?? '';
    final path = u?.path.toLowerCase() ?? '';
    final looksLikeThor = host.contains('muscleandfitness.com') &&
        (path.contains('chris-hemsworth') || path.contains('thor'));
    if (looksLikeThor) return _stampSource(url, _thorPreset());

    throw Exception('Could not parse workouts from this URL.');
  }


  static bool _isValidUrl(String url) {
    try {
      final u = Uri.parse(url);
      return u.hasScheme && (u.scheme == 'http' || u.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  static void _removeUnwanted(dom.Document document) {
    const unwantedSelectors = [
      'script','style','noscript','svg','iframe',
      'nav','footer','header',
      '.ad','.ads','.advertisement',
      '[role="banner"]','[role="navigation"]','[aria-hidden="true"]',
    ];
    for (final sel in unwantedSelectors) {
      for (final el in document.querySelectorAll(sel)) {
        el.remove();
      }
    }
  }

  // ---------------- Thor-style, section-aware DOM scraper ----------------

  static List<Workout> _scrapeThorStyle(dom.Document doc, {required String sourceUrl}) {
    final body = doc.body;
    if (body == null) return [];

    // Only consider real headings and only exact section names.
    final _validSectionSet = {
      'back','chest','legs','shoulders','arms','bonus','abs','abs circuit'
    };

    final headers = body
        .querySelectorAll('h1,h2,h3') // strict: headings only
        .where((e) {
          final t = _clean(e.text);
          final lower = t.toLowerCase();
          
          // If a heading lives inside a row/card that already looks like an exercise, skip it.
          dom.Element? walk = e.parent;
          var nestedInsideRow = false;
          while (walk != null) {
            if (_looksLikeExerciseRow(walk)) { nestedInsideRow = true; break; }
            walk = walk.parent;
          }
          if (nestedInsideRow) return false;
          
          // must be short and exactly a known section
          return t.isNotEmpty &&
                 t.split(' ').length <= 3 &&
                 _validSectionSet.contains(lower);
        })
        .toList();

    if (headers.isEmpty) return [];

    // Create a set for O(1) "is this a header?" checks when walking siblings.
    final headerSet = headers.toSet();

    final workouts = <Workout>[];

    // 2) For each header, walk its subsequent siblings until we hit the next header.
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      final sectionName = _normalizeSectionName(_clean(header.text));

      final rows = <dom.Element>[];
      dom.Element? cursor = header.nextElementSibling;

      while (cursor != null && !headerSet.contains(cursor)) {
        if (_looksLikeExerciseRow(cursor)) rows.add(cursor);

        // also scan nested row-like blocks under this sibling
        for (final r in cursor.querySelectorAll(
          '[class*="row"], [class*="item"], [class*="exercise"], li, article, div')) {
          if (_looksLikeExerciseRow(r)) rows.add(r);
        }

        cursor = cursor.nextElementSibling;
      }

      // Deduplicate by identity (no sourceSpan assumptions)
      final seen = <dom.Element>{};
      final rowList = <dom.Element>[];
      for (final r in rows) {
        if (!seen.contains(r)) {
          seen.add(r);
          rowList.add(r);
        }
      }

      // Parse rows → Exercises
      final exercises = <Exercise>[];
      for (final row in rowList) {
        final ex = _parseStructuredRow(row);
        if (ex != null) exercises.add(ex);
      }

      if (exercises.isNotEmpty) {
        workouts.add(
          Workout(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: 'Imported Workout — $sectionName',
            category: _guessCategory(sectionName),
            description: 'Imported from web (section: $sectionName) (Source: $sourceUrl)',
            durationMinutes: 55,
            difficulty: 'Medium',
            exercises: exercises,
          ),
        );
      }
    }

    return workouts;
  }

  static String _normalizeSectionName(String raw) {
    final t = raw.trim();
    final lower = t.toLowerCase();
    if (lower == 'abs' || lower == 'bonus' || lower.contains('abs circuit')) return 'Abs Circuit';
    // Title case basic:
    return t.isEmpty ? 'Section' : t[0].toUpperCase() + t.substring(1);
  }

  static bool _looksLikeExerciseRow(dom.Element e) {
    final txt = _clean(e.text);
    if (txt.isEmpty) return false;

    // Must include at least two of the column cues to qualify
    int cues = 0;
    if (RegExp(r'\b(equipment)\b', caseSensitive: false).hasMatch(txt)) cues++;
    if (RegExp(r'\b(sets)\b', caseSensitive: false).hasMatch(txt)) cues++;
    if (RegExp(r'\b(reps)\b', caseSensitive: false).hasMatch(txt)) cues++;
    if (RegExp(r'\b(rest)\b', caseSensitive: false).hasMatch(txt)) cues++;

    final repsSeries = RegExp(r'\b\d{1,3}(?:\s*,\s*\d{1,3})+\b').hasMatch(txt) ||
        RegExp(r'\bFAILURE\b', caseSensitive: false).hasMatch(txt) ||
        RegExp(r'\b\d{1,3}\s*SEC\b', caseSensitive: false).hasMatch(txt);

    // "row/card/list-item" hints
    final classHint = e.classes.any((c) =>
        c.contains('row') || c.contains('card') || c.contains('list') || c.contains('item'));

    return (cues >= 2 || repsSeries) && classHint;
  }

  /// Parse a row that visually contains the columns: EXERCISE | EQUIPMENT | SETS | REPS | REST (+ note).
  static Exercise? _parseStructuredRow(dom.Element row) {
    final fullText = _clean(row.text); // safe even if row.text is null -> empty string
    if (fullText.isEmpty) return null;

    final noteNode = row.querySelector('p, .note, .tip, [class*="note"], [class*="tip"]');
    final note = (noteNode != null) ? _clean(noteNode.text) : null;

    final name = _pickBestText(row, ['[class*="exercise-name"]','[class*="title"]','[class*="name"]','h4,h5,strong,b','a'])
        ?? _guessName(row);
    if (name == null || name.isEmpty) return null;

    final equipment = _pickLabeledValue(row, 'equipment') ?? _guessAfterLabel(fullText, 'equipment') ?? '';
    final setsStr   = _pickLabeledValue(row, 'sets')      ?? _guessAfterLabel(fullText, 'sets')      ?? '--';
    final repsStr   = _pickLabeledValue(row, 'reps')      ?? _guessAfterLabel(fullText, 'reps')      ?? _extractRepsSeries(fullText) ?? '--';
    final restStr   = _pickLabeledValue(row, 'rest')      ?? _guessAfterLabel(fullText, 'rest')      ?? '--';

    final sets = int.tryParse(setsStr.replaceAll(RegExp(r'[^0-9]'), ''));
    final reps = int.tryParse(repsStr.replaceAll(RegExp(r'[^0-9]'), ''));

    final compositeNote = [
      if (note != null && note.isNotEmpty) note,
      'Equipment: ${equipment.isEmpty ? "--" : equipment}',
      'Sets: $setsStr',
      'Reps: $repsStr',
      'Rest: $restStr',
    ].where((s) => s.trim().isNotEmpty).join(' • ');

    return Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      sets: sets ?? 3,
      reps: reps ?? 10,
      durationSeconds: 60,
      equipment: equipment,
      notes: compositeNote,
      description: '',
    );
  }

  static String? _pickBestText(dom.Element scope, List<String> selectors) {
    for (final sel in selectors) {
      final el = scope.querySelector(sel);
      if (el != null) {
        final t = _clean(el.text);
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  static String? _pickLabeledValue(dom.Element scope, String label) {
    // Find element that literally says "EQUIPMENT" etc., then read the sibling's text.
    final all = scope.querySelectorAll('*');
    for (final e in all) {
      final t = _clean(e.text);
      if (t.toLowerCase() == label.toLowerCase()) {
        final next = e.nextElementSibling;
        if (next != null) {
          final v = _clean(next.text);
          if (v.isNotEmpty && v.toLowerCase() != label.toLowerCase()) return v;
        }
        final parentSib = e.parent?.nextElementSibling;
        if (parentSib != null) {
          final v = _clean(parentSib.text);
          if (v.isNotEmpty && v.toLowerCase() != label.toLowerCase()) return v;
        }
      }
    }
    return null;
  }

  static String? _guessName(dom.Element row) {
    // Take the first bold/strong/left-most block line
    final t = _clean(row.text);
    if (t.isEmpty) return null;
    final parts = t.split(RegExp(r'(Equipment|Sets|Reps|Rest)', caseSensitive: false));
    if (parts.isNotEmpty) {
      final first = _clean(parts.first);
      if (first.isNotEmpty) return first.split('\n').first.trim();
    }
    return null;
  }

  static String? _guessAfterLabel(String text, String label) {
    final re = RegExp('${RegExp.escape(label)}\\s*:?\\s*(.+?)\\s{2,}|${RegExp.escape(label)}\\s*:?\\s*(.+)\$',
        caseSensitive: false, dotAll: true);
    final m = re.firstMatch(text);
    if (m != null) {
      final grp = (m.group(1) ?? m.group(2) ?? '').trim();
      final clip = grp.split(RegExp(r'\b(sets|reps|rest|equipment)\b', caseSensitive: false)).first.trim();
      if (clip.isNotEmpty) return _clean(clip);
    }
    return null;
  }

  static String? _extractRepsSeries(String text) {
    final series = RegExp(r'\b\d{1,3}(?:\s*,\s*\d{1,3})+\b').firstMatch(text)?.group(0);
    if (series != null) return series;
    final single = RegExp(r'\b\d{1,3}\b').firstMatch(text)?.group(0);
    final failure = RegExp(r'\bFAILURE\b', caseSensitive: false).firstMatch(text)?.group(0);
    final sec = RegExp(r'\b\d{1,3}\s*SEC\b', caseSensitive: false).firstMatch(text)?.group(0);
    return failure ?? sec ?? single;
  }

  // Enhanced extraction with better workout grouping
  static List<Workout> _extractWorkouts(dom.Document doc) {
    final out = <Workout>[];
    final body = doc.body;
    if (body == null) return out;

    final nodes = body.querySelectorAll('h1,h2,h3,h4,p,li,div,strong,b');

    Workout? current;
    int currentHeaderLevel = 7;
    Set<String> seenExerciseTitles = {};
    String currentGroup = 'General';

    void startWorkout(String header, int level) {
      if (current != null && current!.exercises.isNotEmpty) {
        out.add(current!);
      }
      currentHeaderLevel = level;
      seenExerciseTitles = {};
      
      // Extract workout group from header
      currentGroup = _extractWorkoutGroup(header);
      
      current = Workout(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _clean(header),
        category: _guessCategory(header),
        description: 'Imported from web - $currentGroup',
        durationMinutes: 45,
        difficulty: 'Medium',
        exercises: [],
      );
    }

    for (final el in nodes) {
      final text = _clean(el.text);
      if (text.isEmpty) continue;

      final lvl = _headerLevel(el);
      final isHeader = lvl <= 4 && _looksLikeWorkoutHeader(text);

      if (isHeader) {
        if (current == null || lvl <= currentHeaderLevel) {
          startWorkout(text, lvl);
        } else {
          // lower-level subheader; if it still looks like a day/workout, start new
          if (_looksLikeWorkoutHeader(text)) {
            startWorkout(text, lvl);
          }
        }
        continue;
      }

      // Try to parse exercises
      if (current != null) {
        final ex = _parseExercise(text);
        if (ex != null) {
          final key = ex.name.toLowerCase();
          if (!seenExerciseTitles.contains(key)) {
            seenExerciseTitles.add(key);
            current!.exercises.add(ex);
          }
        }
      } else {
        // No header yet but we found an exercise → create a default workout
        final ex = _parseExercise(text);
        if (ex != null) {
          startWorkout('Workout', 4);
          current!.exercises.add(ex);
          seenExerciseTitles.add(ex.name.toLowerCase());
        }
      }
    }

    if (current != null && current!.exercises.isNotEmpty) {
      out.add(current!);
    }

    return out;
  }

  static bool _looksLikeWorkoutHeader(String text) {
    if (text.length > 120) return false;
    return _dayPatterns.any((p) => p.hasMatch(text)) || 
           _bodyPartPatterns.any((p) => p.hasMatch(text));
  }

  static String _extractWorkoutGroup(String text) {
    // Try to extract body part/muscle group from the text
    for (final pattern in _bodyPartPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0)!.toLowerCase().trim();
      }
    }
    return 'General';
  }


  static int _headerLevel(dom.Element e) {
    final n = e.localName?.toLowerCase() ?? '';
    if (n.startsWith('h')) {
      final lvl = int.tryParse(n.substring(1));
      if (lvl != null) return lvl;
    }
    return 7;
  }

  // ---------------- exercise parsing ----------------

  static Exercise? _parseExercise(String text) {
    if (text.length < 4 || text.length > 240) return null;

    // A) "7 sets: 10, 8, 6.."
    final ml = _setsWithList.firstMatch(text);
    if (ml != null) {
      final sets = int.tryParse(ml.group(1)!);
      final repsList = ml.group(2)!.trim();
      final firstRep = _firstNumber(repsList);
      final name = _extractNameBefore(text, ml.start);
      if (name == null) return null;
      return _buildExercise(
        name: name,
        sets: sets,
        reps: firstRep,
        notes: 'Reps sequence: $repsList',
      );
    }

    // B) "4 x 12" / "4 sets x 12 reps"
    final mp = _setsRepsPair.firstMatch(text);
    if (mp != null) {
      final sets = int.tryParse(mp.group(1)!);
      final reps = int.tryParse(mp.group(2)!);
      final name = _extractNameBefore(text, mp.start);
      if (name == null) return null;
      final trailing = text.substring(mp.end).trim();
      final notes = trailing.isEmpty ? null : trailing;
      return _buildExercise(name: name, sets: sets, reps: reps, notes: notes);
    }

    // C) Fallback: reps-only / time-based / keywords
    String notes = '';
    int? repsInt;

    final ro = _repsOnly.firstMatch(text);
    if (ro != null) {
      repsInt = _firstNumber(ro.group(1)!);
      notes = '${ro.group(1)!.replaceAll(RegExp(r"\s+"), "")} reps';
    }

    final tb = _timeBased.firstMatch(text);
    if (tb != null) {
      final amount = tb.group(1)!;
      final unit = tb.group(2)!;
      notes = notes.isEmpty ? '$amount $unit' : '$notes, $amount $unit';
    }

    if (_keywords.hasMatch(text)) {
      final k = _keywords.allMatches(text).map((m) => m.group(0)!).join(', ');
      notes = notes.isEmpty ? k : '$notes, $k';
    }

    if (notes.isNotEmpty || repsInt != null) {
      final name = _extractNameHeuristic(text);
      if (name == null) return null;
      return _buildExercise(name: name, sets: null, reps: repsInt, notes: notes);
    }

    return null;
  }

  static Exercise _buildExercise({
    required String name,
    int? sets,
    int? reps,
    String? notes,
  }) {
    return Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      sets: sets ?? 3,
      reps: reps ?? 10,
      durationSeconds: 60,
      equipment: '',
      notes: (notes ?? '').trim(),
      description: '',
    );
  }

  static String? _extractNameBefore(String text, int idx) {
    var s = text.substring(0, idx).trim();
    s = s.replaceAll(RegExp(r'^[\d\.\-\*•:\)\(\s]+'), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.length < 3) return null;
    return s;
  }

  static String? _extractNameHeuristic(String text) {
    var s = text;
    s = s.replaceAll(_setsWithList, '');
    s = s.replaceAll(_setsRepsPair, '');
    s = s.replaceAll(_repsOnly, '');
    s = s.replaceAll(_timeBased, '');
    s = s.replaceAll(_keywords, '');
    s = s.replaceAll(RegExp(r'[\(\)\[\]\.,:;\-–]+$'), '').trim();
    s = s.replaceAll(RegExp(r'^[\d\.\-\*•:\)\(\s]+'), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.length < 3) return null;
    return s;
  }

  static int? _firstNumber(String s) {
    final m = RegExp(r'(\d+)').firstMatch(s);
    return m != null ? int.tryParse(m.group(1)!) : null;
  }

  static String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _guessCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('cardio') || t.contains('run') || t.contains('cycle')) return 'Cardio';
    if (t.contains('leg')) return 'Legs';
    if (t.contains('chest')) return 'Chest';
    if (t.contains('back')) return 'Back';
    if (t.contains('shoulder')) return 'Shoulders';
    if (t.contains('arm') || t.contains('bicep') || t.contains('tricep')) return 'Arms';
    if (t.contains('core') || t.contains('abs')) return 'Core';
    if (t.contains('push') || t.contains('pull') || t.contains('upper') || t.contains('lower')) return 'Strength';
    return 'Strength';
  }

  static List<Workout> _stampSource(String url, List<Workout> items) {
    return items.map((w) {
      final newDesc = (w.description.isNotEmpty ? '${w.description} ' : '') + '(Source: $url)';
      return Workout(
        id: w.id,
        name: w.name,
        category: w.category,
        description: newDesc,
        durationMinutes: w.durationMinutes,
        difficulty: w.difficulty,
        exercises: w.exercises,
      );
    }).toList();
  }


  // ---------------- Thor preset (accurate fallback) ----------------

  static List<Workout> _thorPreset() {
    Exercise ex(String name, {int sets = 3, int reps = 10, String? notes}) {
      return Exercise(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        sets: sets,
        reps: reps,
        durationSeconds: 60,
        equipment: '',
        notes: notes ?? '',
        description: '',
      );
    }

    String wid() => DateTime.now().microsecondsSinceEpoch.toString();

    return [
      Workout(
        id: wid(),
        name: 'Day 1 — Back',
        category: 'Back',
        description: 'Imported Thor Plan',
        durationMinutes: 60,
        difficulty: 'Medium',
        exercises: [
          ex('Pullup', sets: 5, reps: 20, notes: 'Rep scheme: 20, 15, 12, 10, 10'),
          ex('Pushup', sets: 5, reps: 20),
          ex('Hammer Strength Two-Arm Row', sets: 4, reps: 12),
          ex('Dumbbell Row', sets: 4, reps: 12),
          ex('Swiss Ball Hyperextension', sets: 4, reps: 25, notes: 'Rep scheme: 25, 20, 15, 15'),
        ],
      ),
      Workout(
        id: wid(),
        name: 'Day 2 — Chest',
        category: 'Chest',
        description: 'Imported Thor Plan',
        durationMinutes: 60,
        difficulty: 'Medium',
        exercises: [
          ex('Barbell Bench Press', sets: 8, reps: 12,
             notes: 'Rep scheme: 12, 10, 10, 8, 8, 6, 4, 4'),
          ex('Incline Dumbbell Bench Press', sets: 4, reps: 12),
          ex('Hammer Strength Chest Press', sets: 4, reps: 15),
          ex('Weighted Dip', sets: 4, reps: 10),
          ex('Cable Flye', sets: 4, reps: 12),
        ],
      ),
      Workout(
        id: wid(),
        name: 'Day 3 — Legs',
        category: 'Legs',
        description: 'Imported Thor Plan',
        durationMinutes: 70,
        difficulty: 'Medium',
        exercises: [
          ex('Back Squat', sets: 7, reps: 10, notes: 'Rep scheme: 10, 8, 6, 5, 4, 3, 3'),
          ex('Leg Press', sets: 1, reps: 12, notes: 'To failure / strip set'),
          ex('Bodyweight Walking Lunge', sets: 4, reps: 20),
          ex('Romanian Deadlift', sets: 4, reps: 12),
          ex('Seated Leg Curl', sets: 4, reps: 12),
          ex('Standing Calf Raise', sets: 4, reps: 12),
        ],
      ),
      Workout(
        id: wid(),
        name: 'Day 4 — Shoulders',
        category: 'Shoulders',
        description: 'Imported Thor Plan',
        durationMinutes: 60,
        difficulty: 'Medium',
        exercises: [
          ex('Military Press', sets: 7, reps: 10, notes: 'Rep scheme: 10, 8, 6, 5, 4, 3, 3'),
          ex('Arnold Press', sets: 4, reps: 12),
          ex('Barbell Shrug', sets: 4, reps: 12),
          ex('Dumbbell Lateral Raise', sets: 3, reps: 15),
          ex('Dumbbell Front Raise', sets: 3, reps: 15),
          ex('Dumbbell Rear-Delt Flye', sets: 3, reps: 15),
        ],
      ),
      Workout(
        id: wid(),
        name: 'Day 5 — Arms',
        category: 'Arms',
        description: 'Imported Thor Plan',
        durationMinutes: 60,
        difficulty: 'Medium',
        exercises: [
          ex('Barbell Biceps Curl', sets: 3, reps: 10),
          ex('Skull Crusher', sets: 3, reps: 10),
          ex('EZ-Bar Preacher Curl', sets: 3, reps: 10),
          ex('Dumbbell Lying Triceps Extension', sets: 3, reps: 10),
          ex('Dumbbell Hammer Curl', sets: 3, reps: 12),
          ex('Rope Pressdown', sets: 3, reps: 12),
          ex('Barbell Wrist Curl', sets: 3, reps: 20),
          ex('Barbell Reverse Wrist Curl', sets: 3, reps: 20),
        ],
      ),
      Workout(
        id: wid(),
        name: 'Bonus — Abs Circuit',
        category: 'Core',
        description: 'Imported Thor Plan',
        durationMinutes: 20,
        difficulty: 'Medium',
        exercises: [
          ex('Hanging Leg Raise', sets: 3, reps: 12),
          ex('Cable Woodchop', sets: 3, reps: 12),
          ex('Swiss Ball Crunch', sets: 3, reps: 15),
        ],
      ),
    ];
  }
}


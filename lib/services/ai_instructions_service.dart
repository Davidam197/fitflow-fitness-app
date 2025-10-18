import 'dart:convert';
import 'package:http/http.dart' as http;

class AIInstructionsService {
  final String apiKey;
  final String baseUrl;
  final String model;

  AIInstructionsService({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1/chat/completions',
    this.model = 'gpt-4o-mini',
  });

  Future<String> generate({
    required String exerciseName,
    required int sets,
    required int reps,
    String category = 'Strength',
    String equipment = '',
  }) async {
    final prompt = '''
You are a certified strength & conditioning coach.
Write concise, step-by-step instructions (6–10 bullets) to correctly perform: "$exerciseName".
Context:
- Category: $category
- Prescription: $sets sets × $reps reps
- Equipment: ${equipment.isEmpty ? 'Bodyweight or typical gym equipment' : equipment}

Format:
1) Setup
2) Movement
3) Breathing
4) Common mistakes (2–3 quick bullets)
5) Scaling options (easier/harder)

Use short bullets (max ~15 words each). No emoji.''';

    final body = {
      "model": model,
      "messages": [
        {"role": "system", "content": "You produce short, safe, highly practical exercise instructions."},
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.4,
      "max_tokens": 350
    };

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('AI error ${res.statusCode}: ${res.body}');
    }
  }
}

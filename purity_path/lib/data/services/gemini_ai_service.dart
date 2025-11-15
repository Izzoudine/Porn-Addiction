import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAIService {
  // Multiple API keys with automatic fallback
  static const List<String> _apiKeys = [
    'AIzaSyCjU69uYpF1Vpzi6hld7N7JTn7fC1DS8f4',
    'AIzaSyBxkTG3nyhBac8-SSPF0JHfOP05mpughG0',
    'AIzaSyAFAJdzfIT13bsyfQBBba_itkU33HSscN8',
  ];
  static int _currentKeyIndex = 0;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Get AI response for recovery support
  /// 
  /// Example uses:
  /// - Motivational support during urges
  /// - Trigger analysis
  /// - Islamic guidance
  /// - Progress encouragement
  static Future<String> getRecoverySupport({
    required String userMessage,
    String? context,
  }) async {
    // Try each API key until one works
    for (int i = 0; i < _apiKeys.length; i++) {
      final keyIndex = (_currentKeyIndex + i) % _apiKeys.length;
      final apiKey = _apiKeys[keyIndex];
      
      try {
        final response = await _makeRequest(apiKey, userMessage, context);
        
        if (response != null) {
          // This key works, remember it for next time
          _currentKeyIndex = keyIndex;
          return response;
        }
      } catch (e) {
        print('API key $keyIndex failed: $e');
        // Try next key
        continue;
      }
    }
    
    // All keys failed
    return 'I apologize, I am having trouble connecting right now. Please try again later.';
  }

  /// Internal method to make API request
  static Future<String?> _makeRequest(
    String apiKey,
    String userMessage,
    String? context,
  ) async {
    try {
      final systemPrompt = '''
You are an Islamic recovery counselor helping Muslims overcome porn addiction.
Your responses should be:
- Compassionate and non-judgmental
- Grounded in Islamic teachings (Quran & Hadith)
- Practical and actionable
- Encouraging and hopeful
- Brief (2-3 paragraphs max)

Context about the user: ${context ?? 'First time conversation'}
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': systemPrompt},
                {'text': 'User: $userMessage'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 500,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'Sorry, I could not generate a response.';
      } else if (response.statusCode == 429) {
        // Rate limit exceeded, try next key
        print('Rate limit exceeded for this API key');
        return null;
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Invalid API key, try next key
        print('Invalid API key');
        return null;
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling Gemini AI: $e');
      return null;
    }
  }

  /// Generate personalized motivation based on user's progress
  static Future<String> generateMotivation({
    required int cleanStreak,
    required int totalCleanDays,
    String? currentPhase,
  }) async {
    final message = '''
I'm on day $cleanStreak of my recovery journey. 
Total clean days: $totalCleanDays.
${currentPhase != null ? 'Current phase: $currentPhase' : ''}
Please give me encouragement and motivation.
''';

    return await getRecoverySupport(
      userMessage: message,
      context: 'Recovery progress update',
    );
  }

  /// Analyze triggers and provide coping strategies
  static Future<String> analyzeTriggers({
    required String trigger,
    required String situation,
  }) async {
    final message = '''
I just experienced a trigger: $trigger
Situation: $situation
Can you help me understand this and give me coping strategies?
''';

    return await getRecoverySupport(
      userMessage: message,
      context: 'Trigger analysis and coping',
    );
  }

  /// Get Islamic guidance and relevant verses
  static Future<String> getIslamicGuidance({
    required String question,
  }) async {
    final message = '''
Question about Islamic perspective: $question
Please provide guidance with Quranic verses or Hadith if relevant.
''';

    return await getRecoverySupport(
      userMessage: message,
      context: 'Islamic guidance request',
    );
  }

  /// Emergency support during strong urges
  static Future<String> getEmergencySupport() async {
    final message = '''
I'm experiencing a strong urge right now. I need immediate help and support.
Please give me practical steps to resist this urge.
''';

    return await getRecoverySupport(
      userMessage: message,
      context: 'URGENT: Strong urge/emergency',
    );
  }

  /// Generate personalized recovery plan suggestions
  static Future<String> getRecoveryPlanSuggestions({
    required String frequency,
    required String duration,
    required List<String> triggers,
  }) async {
    final message = '''
Help me create a recovery plan:
- Current frequency: $frequency
- Average duration: $duration minutes
- Main triggers: ${triggers.join(', ')}
What strategies would work best for me?
''';

    return await getRecoverySupport(
      userMessage: message,
      context: 'Recovery plan creation',
    );
  }
}

import 'package:purity_path/data/services/gemini_ai_service.dart';
import 'package:purity_path/data/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI Voice Intervention Service
/// Combines AI-generated responses with Text-to-Speech
/// for real-time audio intervention when porn is detected
class AIVoiceInterventionService {
  static bool _isInterventionActive = false;
  static DateTime? _lastInterventionTime;
  static const int _minInterventionInterval = 30; // seconds

  /// Initialize the service
  static Future<void> initialize() async {
    await TTSService.initialize();
  }

  /// Immediate voice intervention when porn is detected
  static Future<void> onPornDetected({
    int? cleanStreak,
    String? userName,
  }) async {
    if (_isInterventionActive) return;
    if (_shouldSkipIntervention()) return;

    _isInterventionActive = true;
    _lastInterventionTime = DateTime.now();

    try {
      // Stage 1: Immediate stop command (pre-written, no AI delay)
      await TTSService.speak(
        "Stop! Brother, this is not who you are. Take a deep breath with me."
      );

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Stage 2: Get personalized AI intervention (async)
      final prefs = await SharedPreferences.getInstance();
      final streak = cleanStreak ?? prefs.getInt('cleanStreak') ?? 0;
      final name = userName ?? prefs.getString('userName') ?? 'Brother';

      // Generate AI response while speaking continues
      final aiResponseFuture = _getPersonalizedIntervention(streak, name);

      // Stage 3: Islamic reminder while AI generates
      await TTSService.islamicReminder();

      // Stage 4: AI-generated personalized message
      final aiResponse = await aiResponseFuture;
      if (aiResponse.isNotEmpty) {
        await TTSService.speakAIResponse(aiResponse);
      }

    } catch (e) {
      print('Error in voice intervention: $e');
      // Fallback to basic intervention
      await TTSService.pornDetectedIntervention();
    } finally {
      _isInterventionActive = false;
    }
  }

  /// Continuous reminders during porn session (called every 30 seconds)
  static Future<void> onContinuousWatching(int secondsWatching) async {
    if (_isInterventionActive) return;
    if (_shouldSkipIntervention()) return;

    _isInterventionActive = true;
    _lastInterventionTime = DateTime.now();

    try {
      final minutes = secondsWatching ~/ 60;

      if (minutes == 0) {
        // Less than 1 minute - urgent stop
        await TTSService.speak(
          "You're still here. Please, close this now. Think about your family. Think about your goals."
        );
      } else if (minutes < 3) {
        // 1-3 minutes - escalating urgency
        await TTSService.continuousReminder(secondsWatching);
        
        // Get AI-generated coping strategy
        final aiStrategy = await GeminiAIService.getRecoverySupport(
          userMessage: "I've been watching for $minutes minutes and I'm struggling to stop",
          context: "Emergency intervention needed",
        );
        await TTSService.speakAIResponse(aiStrategy);
      } else {
        // 3+ minutes - strong intervention
        await TTSService.speak(
          "You've been here for $minutes minutes. This needs to stop NOW. Stand up, make wudu, and pray 2 rakah."
        );
      }
    } catch (e) {
      print('Error in continuous intervention: $e');
    } finally {
      _isInterventionActive = false;
    }
  }

  /// Emergency support (triggered by user or limit reached)
  static Future<void> triggerEmergencySupport() async {
    try {
      // Immediate calming
      await TTSService.breathingExercise();

      // Get AI emergency support
      final aiSupport = await GeminiAIService.getEmergencySupport();
      await TTSService.speakAIResponse(aiSupport);
    } catch (e) {
      print('Error in emergency support: $e');
      await TTSService.speak(
        "You are stronger than this. Allah is with those who are patient. Close this now."
      );
    }
  }

  /// Motivational intervention
  static Future<void> provideDailyMotivation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final streak = prefs.getInt('cleanStreak') ?? 0;

      final motivation = await GeminiAIService.generateMotivation(
        cleanStreak: streak,
        totalCleanDays: streak,
      );

      await TTSService.speakAIResponse(motivation);
    } catch (e) {
      print('Error providing motivation: $e');
    }
  }

  /// Stop all voice intervention
  static Future<void> stopIntervention() async {
    await TTSService.stop();
    _isInterventionActive = false;
  }

  /// Private helper: Get personalized AI intervention
  static Future<String> _getPersonalizedIntervention(
    int cleanStreak,
    String userName,
  ) async {
    try {
      final message = '''
I just detected porn and I'm about to relapse. 
My clean streak is $cleanStreak days. 
Give me urgent, powerful reasons to stop right now. 
Keep it brief and impactful - I need to hear this immediately.
''';

      final response = await GeminiAIService.getRecoverySupport(
        userMessage: message,
        context: 'URGENT: Active porn session detected',
      );

      // Simplify AI response for speech (remove asterisks, etc.)
      return _cleanTextForSpeech(response);
    } catch (e) {
      print('Error getting AI intervention: $e');
      return '';
    }
  }

  /// Clean AI text for better speech
  static String _cleanTextForSpeech(String text) {
    return text
        .replaceAll('*', '') // Remove markdown
        .replaceAll('#', '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('  ', ' ') // Remove double spaces
        .trim();
  }

  /// Check if we should skip intervention (to avoid spam)
  static bool _shouldSkipIntervention() {
    if (_lastInterventionTime == null) return false;
    
    final timeSinceLastIntervention = 
        DateTime.now().difference(_lastInterventionTime!).inSeconds;
    
    return timeSinceLastIntervention < _minInterventionInterval;
  }

  /// Get settings from SharedPreferences
  static Future<bool> isVoiceInterventionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('enableVoiceIntervention') ?? true; // Default enabled
  }

  /// Enable/disable voice intervention
  static Future<void> setVoiceInterventionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableVoiceIntervention', enabled);
  }
}

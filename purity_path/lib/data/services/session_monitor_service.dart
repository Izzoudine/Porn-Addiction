import 'package:flutter/services.dart';
import 'package:purity_path/data/services/session_tracker.dart';
import 'package:purity_path/data/services/phase_manager.dart';
import 'package:purity_path/data/services/ai_voice_intervention_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionMonitorService {
  static const platform = MethodChannel('com.example.purity_path/session');
  static bool _isInitialized = false;

  /// Initialize the session monitor service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    platform.setMethodCallHandler(_handleMethodCall);
    _isInitialized = true;
    print('SessionMonitorService initialized');
  }

  /// Handle method calls from native (Kotlin)
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('Received method call: ${call.method}');

    switch (call.method) {
      case 'startSession':
        return await _handleStartSession();

      case 'endSession':
        return await _handleEndSession();

      case 'checkLimits':
        final args = call.arguments as Map<dynamic, dynamic>;
        final durationSeconds = args['durationSeconds'] as int;
        return await _handleCheckLimits(durationSeconds);

      default:
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Handle session start from accessibility service
  static Future<void> _handleStartSession() async {
    try {
      await SessionTracker.startSession();
      print('Session started from accessibility service');

      // Trigger AI voice intervention
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('enableVoiceIntervention') ?? true;
      
      if (isEnabled) {
        final cleanStreak = prefs.getInt('cleanStreak') ?? 0;
        final userName = prefs.getString('userName') ?? 'Brother';
        
        // Immediate voice intervention
        AIVoiceInterventionService.onPornDetected(
          cleanStreak: cleanStreak,
          userName: userName,
        );
      }
    } catch (e) {
      print('Error starting session: $e');
    }
  }

  /// Handle session end from accessibility service
  static Future<void> _handleEndSession() async {
    try {
      await SessionTracker.endSession();
      print('Session ended from accessibility service');
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  /// Check if current session exceeds phase limits
  static Future<bool> _handleCheckLimits(int durationSeconds) async {
    try {
      print('Checking limits - Duration: $durationSeconds seconds');

      // Trigger continuous voice reminder every 30 seconds
      if (durationSeconds % 30 == 0 && durationSeconds > 0) {
        final prefs = await SharedPreferences.getInstance();
        final isEnabled = prefs.getBool('enableVoiceIntervention') ?? true;
        
        if (isEnabled) {
          AIVoiceInterventionService.onContinuousWatching(durationSeconds);
        }
      }

      // Get current phase limits
      final currentPhase = await PhaseManager.getCurrentPhase();
      if (currentPhase == null) {
        print('No active phase - allowing session');
        return false; // No phase active, don't block
      }

      // Check duration limit
      if (currentPhase.durationLimit != null &&
          currentPhase.durationLimit! > 0) {
        final durationMinutes = (durationSeconds / 60).ceil();
        if (durationMinutes >= currentPhase.durationLimit!) {
          print(
            'Duration limit exceeded: $durationMinutes/${currentPhase.durationLimit} minutes',
          );
          
          // Trigger emergency support when limit reached
          AIVoiceInterventionService.triggerEmergencySupport();
          return true; // Block - duration limit exceeded
        }
      }

      // Check frequency limit
      if (currentPhase.frequencyLimit != null &&
          currentPhase.frequencyLimit! > 0) {
        final weeklyCount = await SessionTracker.getWeeklySessionCount();
        if (weeklyCount >= currentPhase.frequencyLimit!) {
          print(
            'Frequency limit exceeded: $weeklyCount/${currentPhase.frequencyLimit} sessions this week',
          );
          return true; // Block - frequency limit exceeded
        }
      }

      print('Within limits - allowing session');
      return false; // Within limits, don't block
    } catch (e) {
      print('Error checking limits: $e');
      return false; // On error, don't block
    }
  }
}

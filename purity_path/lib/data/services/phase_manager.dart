import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reduction_phase.dart';
import 'session_tracker.dart';

class PhaseManager {
  static const String _phaseKey = 'reduction_phases';
  static const String _currentPhaseKey = 'current_phase_index';
  static const String _planStartDateKey = 'plan_start_date';

  /// Generate the complete reduction plan based on initial frequency and duration
  static List<ReductionPhase> generateReductionPlan({
    required int initialDurationMinutes,
    required int initialFrequencyPerWeek,
  }) {
    final List<ReductionPhase> phases = [];
    int phaseNumber = 1;
    int weekCounter = 1;
    final DateTime startDate = DateTime.now();

    // PHASE 1: Reduce Duration per Session
    final durationPhases = _generateDurationPhases(
      initialDurationMinutes,
      phaseNumber,
      weekCounter,
      startDate,
    );
    phases.addAll(durationPhases);
    phaseNumber += durationPhases.length;
    weekCounter += durationPhases.length;

    // PHASE 2: Reduce Weekly Frequency
    final frequencyPhases = _generateFrequencyPhases(
      initialFrequencyPerWeek,
      phaseNumber,
      weekCounter,
      startDate,
    );
    phases.addAll(frequencyPhases);
    phaseNumber += frequencyPhases.length;
    weekCounter += frequencyPhases.length;

    // PHASE 3: Reduce to Biweekly
    phases.add(
      ReductionPhase(
        phaseNumber: phaseNumber,
        phaseType: 'spacing',
        weekNumber: weekCounter,
        durationLimit: 10,
        frequencyLimit: 1,
        spacingLimit: 'biweekly',
        description: 'Reduce to once every 2 weeks (10 min max)',
        startDate: startDate.add(Duration(days: (weekCounter - 1) * 7)),
      ),
    );
    phaseNumber++;
    weekCounter += 2; // Biweekly period

    // PHASE 4: Reduce to Monthly
    phases.add(
      ReductionPhase(
        phaseNumber: phaseNumber,
        phaseType: 'spacing',
        weekNumber: weekCounter,
        durationLimit: 10,
        frequencyLimit: 1,
        spacingLimit: 'monthly',
        description: 'Reduce to once a month (10 min max)',
        startDate: startDate.add(Duration(days: (weekCounter - 1) * 7)),
      ),
    );
    phaseNumber++;
    weekCounter += 4; // Monthly period

    // FINAL PHASE: Complete Control
    phases.add(
      ReductionPhase(
        phaseNumber: phaseNumber,
        phaseType: 'complete',
        weekNumber: weekCounter,
        durationLimit: 0,
        frequencyLimit: 0,
        spacingLimit: 'complete_control',
        description: 'Complete control achieved - No compulsion',
        startDate: startDate.add(Duration(days: (weekCounter - 1) * 7)),
      ),
    );

    return phases;
  }

  /// Generate duration reduction phases (Phase 1)
  static List<ReductionPhase> _generateDurationPhases(
    int initialDuration,
    int startingPhaseNumber,
    int startingWeek,
    DateTime planStartDate,
  ) {
    final List<ReductionPhase> phases = [];
    int currentDuration = initialDuration;
    int phaseNum = startingPhaseNumber;
    int weekNum = startingWeek;

    // Reduce duration by approximately 1/3 each week until we reach 10 minutes
    while (currentDuration > 10) {
      // Calculate next duration (reduce by ~1/3, rounded to nearest 10)
      int nextDuration = ((currentDuration * 2 / 3) / 10).round() * 10;
      if (nextDuration < 10) nextDuration = 10;
      if (nextDuration >= currentDuration) nextDuration = currentDuration - 10;

      phases.add(
        ReductionPhase(
          phaseNumber: phaseNum,
          phaseType: 'duration',
          weekNumber: weekNum,
          durationLimit: nextDuration,
          description: 'Reduce session duration to $nextDuration minutes',
          startDate: planStartDate.add(Duration(days: (weekNum - 1) * 7)),
        ),
      );

      currentDuration = nextDuration;
      phaseNum++;
      weekNum++;
    }

    return phases;
  }

  /// Generate frequency reduction phases (Phase 2)
  static List<ReductionPhase> _generateFrequencyPhases(
    int initialFrequency,
    int startingPhaseNumber,
    int startingWeek,
    DateTime planStartDate,
  ) {
    final List<ReductionPhase> phases = [];
    int currentFrequency = initialFrequency;
    int phaseNum = startingPhaseNumber;
    int weekNum = startingWeek;

    // Reduce frequency until we reach 1 time per week
    while (currentFrequency > 1) {
      int nextFrequency;

      if (currentFrequency >= 4) {
        // Reduce by 2 if currently 4-7 times/week
        nextFrequency = currentFrequency - 2;
        if (nextFrequency < 1) nextFrequency = 1;
      } else {
        // Reduce by 1 if currently 2-3 times/week
        nextFrequency = currentFrequency - 1;
      }

      phases.add(
        ReductionPhase(
          phaseNumber: phaseNum,
          phaseType: 'frequency',
          weekNumber: weekNum,
          durationLimit: 10, // Duration already reduced to 10 min
          frequencyLimit: nextFrequency,
          description:
              'Reduce frequency to $nextFrequency time${nextFrequency > 1 ? 's' : ''} per week',
          startDate: planStartDate.add(Duration(days: (weekNum - 1) * 7)),
        ),
      );

      currentFrequency = nextFrequency;
      phaseNum++;
      weekNum++;
    }

    return phases;
  }

  /// Save the reduction plan to SharedPreferences and Firestore
  static Future<void> savePlan(List<ReductionPhase> phases) async {
    final prefs = await SharedPreferences.getInstance();
    final phasesJson = phases.map((phase) => phase.toJson()).toList();
    await prefs.setString(_phaseKey, jsonEncode(phasesJson));
    await prefs.setInt(_currentPhaseKey, 0);
    await prefs.setString(_planStartDateKey, DateTime.now().toIso8601String());

    // Also save to Firestore for syncing across devices
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'reductionPlan': {
            'phases': phasesJson,
            'currentPhaseIndex': 0,
            'planStartDate': DateTime.now().toIso8601String(),
          },
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error saving plan to Firestore: $e');
      }
    }
  }

  /// Load the reduction plan from SharedPreferences or Firestore
  static Future<List<ReductionPhase>?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    String? phasesString = prefs.getString(_phaseKey);

    // If not in local storage, try loading from Firestore
    if (phasesString == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();

          if (doc.exists) {
            final data = doc.data();

            // Check if reduction plan exists in Firestore
            if (data?['reductionPlan'] != null) {
              final planData = data!['reductionPlan'];
              phasesString = jsonEncode(planData['phases']);

              // Save to local storage for faster access
              await prefs.setString(_phaseKey, phasesString);
              if (planData['currentPhaseIndex'] != null) {
                await prefs.setInt(
                  _currentPhaseKey,
                  planData['currentPhaseIndex'],
                );
              }
              if (planData['planStartDate'] != null) {
                await prefs.setString(
                  _planStartDateKey,
                  planData['planStartDate'],
                );
              }
            }
            // If no plan but questionnaire was completed, generate it now
            else if (data?['hasCompletedQuestionnaire'] == true &&
                data?['frequency'] != null &&
                data?['quantity'] != null) {
              final frequency = data!['frequency'] as int;
              final quantity = data['quantity'] as int;

              // Generate the plan
              final phases = generateReductionPlan(
                initialDurationMinutes: quantity,
                initialFrequencyPerWeek: frequency,
              );

              // Save it
              await savePlan(phases);

              return phases;
            }
          }
        } catch (e) {
          print('Error loading plan from Firestore: $e');
        }
      }
    }

    if (phasesString == null) return null;

    final List<dynamic> phasesJson = jsonDecode(phasesString);
    return phasesJson.map((json) => ReductionPhase.fromJson(json)).toList();
  }

  /// Get the current active phase
  static Future<ReductionPhase?> getCurrentPhase() async {
    final phases = await loadPlan();
    if (phases == null || phases.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_currentPhaseKey) ?? 0;

    if (currentIndex >= phases.length) {
      return phases.last; // Return final phase if completed
    }

    return phases[currentIndex];
  }

  /// Move to the next phase
  static Future<bool> advanceToNextPhase() async {
    final prefs = await SharedPreferences.getInstance();
    final phases = await loadPlan();

    if (phases == null || phases.isEmpty) return false;

    final currentIndex = prefs.getInt(_currentPhaseKey) ?? 0;

    if (currentIndex >= phases.length - 1) {
      return false; // Already at final phase
    }

    // Mark current phase as completed
    phases[currentIndex] = phases[currentIndex].copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
    );

    // Save updated phases
    final phasesJson = phases.map((phase) => phase.toJson()).toList();
    await prefs.setString(_phaseKey, jsonEncode(phasesJson));

    // Move to next phase
    await prefs.setInt(_currentPhaseKey, currentIndex + 1);

    return true;
  }

  /// Get progress percentage
  static Future<double> getProgressPercentage() async {
    final phases = await loadPlan();
    if (phases == null || phases.isEmpty) return 0.0;

    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_currentPhaseKey) ?? 0;

    return (currentIndex / phases.length) * 100;
  }

  /// Check if a session should be allowed based on current phase
  /// Now includes 24-hour cooldown check
  static Future<Map<String, dynamic>> canStartSession() async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) {
      return {'allowed': true, 'reason': 'no_plan'};
    }

    // Check 24-hour cooldown and weekly limit
    final weeklyLimit = currentPhase.frequencyLimit ?? 999;
    final cooldownCheck = await SessionTracker.canStartNewSession(weeklyLimit);

    return cooldownCheck;
  }

  /// Check if current session should be blocked based on duration
  static Future<Map<String, dynamic>> shouldBlockCurrentSession({
    required int sessionDurationSeconds,
  }) async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) {
      return {'shouldBlock': false};
    }

    final sessionMinutes = (sessionDurationSeconds / 60).ceil();

    // Check duration limit
    if (currentPhase.durationLimit != null && currentPhase.durationLimit! > 0) {
      if (sessionMinutes >= currentPhase.durationLimit!) {
        return {
          'shouldBlock': true,
          'reason': 'duration_limit',
          'message':
              'Session duration limit of ${currentPhase.durationLimit} minutes reached',
          'limit': currentPhase.durationLimit,
          'current': sessionMinutes,
        };
      }
    }

    return {'shouldBlock': false};
  }

  /// Get session start information to show user
  /// Call this when user starts a session to show limits and remaining time
  static Future<Map<String, dynamic>> getSessionStartInfo() async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) {
      return {
        'hasLimits': false,
        'message': 'No active plan - enjoy responsibly',
      };
    }

    final durationLimit = currentPhase.durationLimit ?? 999;
    final weeklyLimit = currentPhase.frequencyLimit ?? 999;

    final info = await SessionTracker.getSessionStartInfo(
      durationLimitMinutes: durationLimit,
      weeklyLimit: weeklyLimit,
    );

    return {
      'hasLimits': true,
      'phaseNumber': currentPhase.phaseNumber,
      'phaseType': currentPhase.phaseType,
      'phaseDescription': currentPhase.description,
      ...info,
    };
  }

  /// Get remaining time for current session
  /// Call this periodically during a session to show countdown
  static Future<Map<String, dynamic>> getCurrentSessionRemainingTime() async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) {
      return {'hasTimeRemaining': false};
    }

    final durationLimit = currentPhase.durationLimit ?? 999;
    return await SessionTracker.getCurrentSessionRemainingTime(durationLimit);
  }

  /// Legacy method - deprecated, use canStartSession instead
  @deprecated
  static Future<bool> isSessionAllowed({
    required int sessionDurationSeconds,
    required int sessionsThisWeek,
  }) async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) return true; // No plan active

    final sessionMinutes = (sessionDurationSeconds / 60).ceil();

    // Check duration limit
    if (currentPhase.durationLimit != null) {
      if (sessionMinutes >= currentPhase.durationLimit!) {
        return false; // Duration limit reached
      }
    }

    // Check frequency limit
    if (currentPhase.frequencyLimit != null) {
      if (sessionsThisWeek >= currentPhase.frequencyLimit!) {
        return false; // Frequency limit reached
      }
    }

    return true;
  }

  /// Get a human-readable description of current limits
  static Future<String> getCurrentLimitsDescription() async {
    final currentPhase = await getCurrentPhase();
    if (currentPhase == null) return 'No active plan';

    final parts = <String>[];

    if (currentPhase.durationLimit != null && currentPhase.durationLimit! > 0) {
      parts.add('${currentPhase.durationLimit} min per session');
    }

    if (currentPhase.frequencyLimit != null &&
        currentPhase.frequencyLimit! > 0) {
      parts.add(
        '${currentPhase.frequencyLimit} time${currentPhase.frequencyLimit! > 1 ? 's' : ''}/week',
      );
    }

    // Add 24-hour cooldown info
    parts.add('24-hour cooldown between sessions');

    if (currentPhase.spacingLimit != null) {
      switch (currentPhase.spacingLimit) {
        case 'biweekly':
          parts.add('Once every 2 weeks');
          break;
        case 'monthly':
          parts.add('Once per month');
          break;
        case 'complete_control':
          return 'Complete Control Achieved! 🎉';
      }
    }

    return parts.isEmpty ? 'No limits active' : parts.join(' • ');
  }

  /// Get user-friendly block message based on reason
  static Future<String> getBlockMessage(String reason) async {
    final currentPhase = await getCurrentPhase();

    switch (reason) {
      case 'cooldown':
        final hoursRemaining = await SessionTracker.getHoursUntilNextSession();
        return 'Please wait $hoursRemaining hour${hoursRemaining > 1 ? 's' : ''} before your next session.\n\nRemember: Patience strengthens willpower! 💪';

      case 'weekly_limit':
        final weeklyCount = await SessionTracker.getWeeklySessionCount();
        final limit = currentPhase?.frequencyLimit ?? 0;
        return 'You\'ve used all $limit sessions for this week ($weeklyCount/$limit).\n\nWeekly limit resets on Monday. Stay strong! 🌟';

      case 'duration_limit':
        final limit = currentPhase?.durationLimit ?? 0;
        return 'Session duration limit of $limit minutes reached.\n\nTake a break and come back tomorrow! 🙏';

      default:
        return 'Session blocked. Remember your goals! 🎯';
    }
  }

  /// Reset the entire plan
  static Future<void> resetPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phaseKey);
    await prefs.remove(_currentPhaseKey);
    await prefs.remove(_planStartDateKey);
  }
}

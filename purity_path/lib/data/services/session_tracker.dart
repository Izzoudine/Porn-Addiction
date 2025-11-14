import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionTracker {
  static const String _sessionsKey = 'content_sessions';
  static const String _currentSessionKey = 'current_session';
  static const String _weeklyCountKey = 'weekly_session_count';
  static const String _lastWeekResetKey = 'last_week_reset';
  static const String _lastSessionEndTimeKey = 'last_session_end_time';
  static const int _cooldownHours = 24; // 24-hour cooldown between sessions

  /// Start tracking a new session
  static Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();

    final sessionData = {
      'startTime': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    await prefs.setString(_currentSessionKey, jsonEncode(sessionData));
  }

  /// End the current session and record it
  static Future<void> endSession() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSessionStr = prefs.getString(_currentSessionKey);

    if (currentSessionStr == null) return;

    final currentSession = jsonDecode(currentSessionStr);
    final startTime = DateTime.parse(currentSession['startTime']);
    final endTime = DateTime.now();
    final durationSeconds = endTime.difference(startTime).inSeconds;

    // Only record sessions longer than 1 minute
    if (durationSeconds >= 60) {
      await _recordSession(startTime, endTime, durationSeconds);
      await _incrementWeeklyCount();
      // Save the end time for 24-hour cooldown check
      await prefs.setString(_lastSessionEndTimeKey, endTime.toIso8601String());
    }

    // Clear current session
    await prefs.remove(_currentSessionKey);
  }

  /// Check if user can start a new session (24-hour cooldown + weekly limit)
  static Future<Map<String, dynamic>> canStartNewSession(
    int weeklyLimit,
  ) async {
    // Check 1: Has 24 hours passed since last session?
    final prefs = await SharedPreferences.getInstance();
    final lastSessionEndStr = prefs.getString(_lastSessionEndTimeKey);

    if (lastSessionEndStr != null) {
      final lastSessionEnd = DateTime.parse(lastSessionEndStr);
      final now = DateTime.now();
      final hoursSinceLastSession = now.difference(lastSessionEnd).inHours;

      if (hoursSinceLastSession < _cooldownHours) {
        final hoursRemaining = _cooldownHours - hoursSinceLastSession;
        return {
          'allowed': false,
          'reason': 'cooldown',
          'message': 'Please wait $hoursRemaining hours before next session',
          'hoursRemaining': hoursRemaining,
        };
      }
    }

    // Check 2: Weekly limit reached?
    final weeklyCount = await getWeeklySessionCount();
    if (weeklyCount >= weeklyLimit) {
      return {
        'allowed': false,
        'reason': 'weekly_limit',
        'message': 'Weekly limit of $weeklyLimit sessions reached',
        'sessionsUsed': weeklyCount,
        'weeklyLimit': weeklyLimit,
      };
    }

    // Both checks passed - allow session
    return {
      'allowed': true,
      'sessionsUsed': weeklyCount,
      'weeklyLimit': weeklyLimit,
    };
  }

  /// Get time remaining until next session is allowed (in hours)
  static Future<int> getHoursUntilNextSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSessionEndStr = prefs.getString(_lastSessionEndTimeKey);

    if (lastSessionEndStr == null) return 0; // No previous session

    final lastSessionEnd = DateTime.parse(lastSessionEndStr);
    final now = DateTime.now();
    final hoursSinceLastSession = now.difference(lastSessionEnd).inHours;

    if (hoursSinceLastSession >= _cooldownHours) return 0; // Cooldown passed

    return _cooldownHours - hoursSinceLastSession;
  }

  /// Get session start info with remaining time and limits
  /// Returns information to show user when they start a session
  static Future<Map<String, dynamic>> getSessionStartInfo({
    required int durationLimitMinutes,
    required int weeklyLimit,
  }) async {
    final weeklyCount = await getWeeklySessionCount();
    final sessionsRemaining = weeklyLimit - weeklyCount;

    // Calculate when next session will be available (after this one)
    final now = DateTime.now();
    final nextAvailableTime = now.add(Duration(hours: _cooldownHours));

    return {
      'durationLimit': durationLimitMinutes,
      'durationLimitSeconds': durationLimitMinutes * 60,
      'timeRemainingMinutes': durationLimitMinutes,
      'timeRemainingSeconds': durationLimitMinutes * 60,
      'sessionsUsed': weeklyCount,
      'sessionsRemaining': sessionsRemaining,
      'weeklyLimit': weeklyLimit,
      'nextSessionAvailableAt': nextAvailableTime.toIso8601String(),
      'nextSessionAvailableIn': '$_cooldownHours hours',
      'message': _buildStartMessage(
        durationLimitMinutes,
        weeklyCount,
        sessionsRemaining,
        weeklyLimit,
      ),
    };
  }

  /// Build user-friendly start message
  static String _buildStartMessage(
    int durationLimit,
    int sessionsUsed,
    int sessionsRemaining,
    int weeklyLimit,
  ) {
    final parts = <String>[];

    // Duration info
    parts.add('⏱️ Time allowed: $durationLimit minutes');

    // Weekly sessions info
    if (sessionsRemaining > 0) {
      parts.add('📊 Sessions: ${sessionsUsed + 1}/$weeklyLimit this week');
      parts.add(
        '✅ $sessionsRemaining session${sessionsRemaining > 1 ? 's' : ''} left after this',
      );
    } else {
      parts.add('⚠️ This is your LAST session this week!');
    }

    // Cooldown reminder
    parts.add('🔄 Next session available in 24 hours');

    return parts.join('\n');
  }

  /// Get remaining time for current active session (in seconds)
  static Future<Map<String, dynamic>> getCurrentSessionRemainingTime(
    int durationLimitMinutes,
  ) async {
    final currentDuration = await getCurrentSessionDuration();
    final durationLimitSeconds = durationLimitMinutes * 60;
    final remainingSeconds = durationLimitSeconds - currentDuration;

    if (remainingSeconds <= 0) {
      return {
        'hasTimeRemaining': false,
        'remainingSeconds': 0,
        'remainingMinutes': 0,
        'currentDuration': currentDuration,
        'message': '⏰ Time limit reached!',
      };
    }

    final remainingMinutes = (remainingSeconds / 60).ceil();
    final percentage = (currentDuration / durationLimitSeconds * 100).toInt();

    String message;
    if (remainingMinutes > 5) {
      message = '⏱️ $remainingMinutes minutes remaining';
    } else if (remainingMinutes > 1) {
      message = '⚠️ Only $remainingMinutes minutes left!';
    } else {
      message = '🚨 Less than 1 minute remaining!';
    }

    return {
      'hasTimeRemaining': true,
      'remainingSeconds': remainingSeconds,
      'remainingMinutes': remainingMinutes,
      'currentDuration': currentDuration,
      'currentMinutes': (currentDuration / 60).floor(),
      'percentageUsed': percentage,
      'message': message,
    };
  }

  /// Check if there's an active session
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSessionStr = prefs.getString(_currentSessionKey);

    if (currentSessionStr == null) return false;

    final currentSession = jsonDecode(currentSessionStr);
    return currentSession['isActive'] == true;
  }

  /// Get current session duration in seconds
  static Future<int> getCurrentSessionDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSessionStr = prefs.getString(_currentSessionKey);

    if (currentSessionStr == null) return 0;

    final currentSession = jsonDecode(currentSessionStr);
    final startTime = DateTime.parse(currentSession['startTime']);
    final now = DateTime.now();

    return now.difference(startTime).inSeconds;
  }

  /// Record a completed session
  static Future<void> _recordSession(
    DateTime startTime,
    DateTime endTime,
    int durationSeconds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsStr = prefs.getString(_sessionsKey) ?? '[]';
    final List<dynamic> sessions = jsonDecode(sessionsStr);

    sessions.add({
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
    });

    await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }

  /// Get all recorded sessions
  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsStr = prefs.getString(_sessionsKey) ?? '[]';
    final List<dynamic> sessions = jsonDecode(sessionsStr);

    return sessions.cast<Map<String, dynamic>>();
  }

  /// Get sessions for this week
  static Future<List<Map<String, dynamic>>> getWeeklySessions() async {
    final allSessions = await getAllSessions();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return allSessions.where((session) {
      final sessionDate = DateTime.parse(session['startTime']);
      return sessionDate.isAfter(weekStart);
    }).toList();
  }

  /// Get count of sessions this week
  static Future<int> getWeeklySessionCount() async {
    await _checkAndResetWeeklyCount();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weeklyCountKey) ?? 0;
  }

  /// Increment weekly session count
  static Future<void> _incrementWeeklyCount() async {
    await _checkAndResetWeeklyCount();
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_weeklyCountKey) ?? 0;
    await prefs.setInt(_weeklyCountKey, currentCount + 1);
  }

  /// Check if we need to reset weekly count (new week started)
  static Future<void> _checkAndResetWeeklyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_lastWeekResetKey);
    final now = DateTime.now();

    if (lastResetStr == null) {
      // First time, set current week
      await prefs.setString(_lastWeekResetKey, now.toIso8601String());
      await prefs.setInt(_weeklyCountKey, 0);
      return;
    }

    final lastReset = DateTime.parse(lastResetStr);
    final daysSinceReset = now.difference(lastReset).inDays;

    // Reset if it's been 7 or more days OR if it's a new week (Monday)
    if (daysSinceReset >= 7 || (now.weekday == 1 && lastReset.weekday != 1)) {
      await prefs.setString(_lastWeekResetKey, now.toIso8601String());
      await prefs.setInt(_weeklyCountKey, 0);
    }
  }

  /// Get average session duration
  static Future<double> getAverageSessionDuration() async {
    final sessions = await getAllSessions();
    if (sessions.isEmpty) return 0.0;

    final totalSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + (session['durationSeconds'] as int),
    );

    return totalSeconds / sessions.length / 60; // Return in minutes
  }

  /// Get total time spent (all time)
  static Future<int> getTotalTimeSpent() async {
    final sessions = await getAllSessions();

    return sessions.fold<int>(
      0,
      (sum, session) => sum + (session['durationSeconds'] as int),
    );
  }

  /// Clear all session data
  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    await prefs.remove(_currentSessionKey);
    await prefs.remove(_weeklyCountKey);
    await prefs.remove(_lastWeekResetKey);
  }
}

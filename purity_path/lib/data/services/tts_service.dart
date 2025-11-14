import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:purity_path/widgets/voice_animation_overlay.dart';

/// Text-to-Speech Service for AI voice intervention
/// Provides real-time audio support when porn is detected
class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;
  static OverlayEntry? _currentOverlay;
  static BuildContext? _context;

  /// Set the context for showing overlays
  static void setContext(BuildContext context) {
    _context = context;
  }

  /// Remove overlay context (call when navigating away)
  static void removeContext() {
    _context = null;
    hideVisualOverlay();
  }

  /// Initialize TTS with optimal settings
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slower, more calming
      await _flutterTts.setVolume(1.0); // Full volume
      await _flutterTts.setPitch(1.0); // Normal pitch
      
      // Set voice (prefer female voice for calming effect)
      await _flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});

      // Set up callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        hideVisualOverlay();
      });

      _flutterTts.setErrorHandler((msg) {
        print("TTS Error: $msg");
        _isSpeaking = false;
      });

      _isInitialized = true;
      print("TTS Service initialized successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  /// Speak text immediately (interrupts any current speech)
  /// Shows visual voice animation overlay
  static Future<void> speak(String text, {bool showVisual = true}) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Stop any current speech
      await stop();
      
      // Show visual overlay if context available
      if (showVisual && _context != null) {
        showVisualOverlay(text);
      }
      
      // Speak the new text
      await _flutterTts.speak(text);
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  /// Show visual voice animation overlay
  static void showVisualOverlay(String message) {
    if (_context == null) return;
    
    hideVisualOverlay(); // Remove any existing overlay
    
    _currentOverlay = OverlayEntry(
      builder: (context) => VoiceAnimationOverlay(
        message: message,
        isAISpeaking: _isSpeaking,
        onClose: () {
          hideVisualOverlay();
          stop();
        },
      ),
    );
    
    Overlay.of(_context!).insert(_currentOverlay!);
  }

  /// Hide visual overlay
  static void hideVisualOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Stop current speech
  static Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
    hideVisualOverlay();
  }

  /// Pause current speech
  static Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Check if currently speaking
  static bool get isSpeaking => _isSpeaking;

  /// Immediate intervention when porn is detected
  static Future<void> pornDetectedIntervention() async {
    const message = '''
    Stop! Brother, this is not who you are. 
    Remember Allah is watching. 
    You are stronger than this urge. 
    Take three deep breaths with me. 
    Breathe in... and out. 
    You can overcome this. 
    Close this now and make wudu.
    ''';
    
    await speak(message);
  }

  /// Continuous reminder during porn session
  static Future<void> continuousReminder(int secondsWatching) async {
    final minutes = secondsWatching ~/ 60;
    final message = '''
    You've been here for $minutes ${minutes == 1 ? 'minute' : 'minutes'}. 
    This is not bringing you closer to Allah. 
    Your family deserves better. 
    You deserve better. 
    Stop now and seek forgiveness.
    ''';
    
    await speak(message);
  }

  /// Motivational support with AI-generated content
  static Future<void> speakAIResponse(String aiResponse) async {
    await speak(aiResponse);
  }

  /// Islamic reminder
  static Future<void> islamicReminder() async {
    const message = '''
    Allah says in the Quran: 
    And those who guard their chastity, 
    except with their spouses, 
    are indeed successful believers. 
    Remember, Allah is Most Merciful. 
    Seek His forgiveness now.
    ''';
    
    await speak(message);
  }

  /// Emergency calm-down technique
  static Future<void> breathingExercise() async {
    const message = '''
    Let's do a breathing exercise together. 
    Breathe in slowly for 4 counts. 
    1... 2... 3... 4. 
    Hold for 4 counts. 
    1... 2... 3... 4. 
    Now breathe out for 4 counts. 
    1... 2... 3... 4. 
    You are in control.
    ''';
    
    await speak(message);
  }

  /// Personalized intervention based on user data
  static Future<void> personalizedIntervention({
    required int cleanStreak,
    required String userName,
  }) async {
    final message = '''
    $userName, stop! 
    You've been clean for $cleanStreak days. 
    Don't throw away all that progress. 
    Remember why you started this journey. 
    Your future self will thank you for stopping now.
    ''';
    
    await speak(message);
  }
}

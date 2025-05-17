import 'package:flutter/services.dart';

class AccessibilityService {
  static const platform = MethodChannel('com.example.purity_path/accessibility');

  static Future<void> requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (e) {
      print("Failed to request accessibility permission: ${e.message}");
    }
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityServiceEnabled');
      return isEnabled;
    } on PlatformException catch (e) {
      print("Error checking accessibility service: ${e.message}");
      return false;
    }
  }
}
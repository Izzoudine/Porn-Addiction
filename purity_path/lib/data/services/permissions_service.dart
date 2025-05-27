import 'package:flutter/services.dart';
import 'package:device_policy_manager/device_policy_manager.dart';

class PermissionService {
  static const platform = MethodChannel(
    'com.example.purity_path/accessibility',
  );
  static Future<bool> requestDeviceAdminPermission(String message) async {
    try {
      return await DevicePolicyManager.requestPermession(message);
    } on PlatformException catch (e) {
      print("Failed to request device admin permission: ${e.message}");
      return false;
    }
  }

  static Future<bool> isDeviceAdminPermissionGranted() async {
    try {
      print(await DevicePolicyManager.isPermissionGranted());
      return await DevicePolicyManager.isPermissionGranted();
    } on PlatformException catch (e) {
      print("Error checking device admin permission: ${e.message}");
      return false;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (e) {
      print("Failed to request accessibility permission: ${e.message}");
      rethrow;
    }
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool isEnabled = await platform.invokeMethod(
        'isAccessibilityServiceEnabled',
      );
      print("Accessibility service check result: $isEnabled");
      return isEnabled;
    } on PlatformException catch (e) {
      print(
        "Error checking accessibility service: ${e.message}, code: ${e.code}, details: ${e.details}",
      );
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await platform.invokeMethod('requestIgnoreBatteryOptimizations');
    } on PlatformException catch (e) {
      print("Failed to request battery optimization exemption: ${e.message}");
      rethrow;
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool isIgnoring = await platform.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return isIgnoring;
    } on PlatformException catch (e) {
      print("Error checking battery optimization status: ${e.message}");
      return false;
    }
  }

  static Future<void> requestNotificationPermission() async {
    try {
      await platform.invokeMethod('requestNotificationPermission');
    } on PlatformException catch (e) {
      print("Failed to request notification permission: ${e.message}");
      rethrow;
    }
  }

  static Future<bool> isNotificationPermissionGranted() async {
    try {
      final bool isGranted = await platform.invokeMethod(
        'isNotificationPermissionGranted',
      );
      return isGranted;
    } on PlatformException catch (e) {
      print("Error checking notification permission: ${e.message}");
      return false;
    }
  }


}

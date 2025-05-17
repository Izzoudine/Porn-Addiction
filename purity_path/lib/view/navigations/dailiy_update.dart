import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/daily_model.dart';
import 'dailies_manager.dart';

class DailiesUpdater {
  // Force update the dailies data regardless of current state
  static const String _prefsKey = 'dailies_data';

  static Future<void> forceUpdateDailies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Remove existing data to force update
      await prefs.remove(_prefsKey);
      // Now check update and fetch
      return await DailiesManager.fetchAndSaveDailiesOnce();
    } catch (e) {
      print('Error force updating dailies: $e');
      return null;
    }
  }

  // Check for updates on app start
  static Future<void> checkForUpdatesOnStart() async {
    try {
      // First check if we need to update based on app version or last update time
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateTime = prefs.getInt('last_dailies_update_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // If it's been more than 24 hours since last update check, check again
      if (currentTime - lastUpdateTime > 24 * 60 * 60 * 1000) {
        final updated = await DailiesManager.checkUpdateAndFetchData();
        if (updated) {
          // If updated successfully, save the update time
          await prefs.setInt('last_dailies_update_time', currentTime);
        }
      } else {
        print("Time has not passed");
      }
    } catch (e) {
      print('Error checking for updates on start: $e');
    }
  }

  // Show a dialog to the user that updates are available
  static Future<void> showUpdateDialog(BuildContext context) async {
    try {
      // First check if update is needed
      final verifySnapshot =
          await FirebaseFirestore.instance
              .collection('admin')
              .doc('verify data')
              .get();

      final needsUpdate = verifySnapshot.data()?['update data'] ?? false;

      if (!needsUpdate) {
        return;
      }

      // Show dialog to user
      final shouldUpdate =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Update Available'),
                  content: Text(
                    'New content is available. Would you like to update now?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Later'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Update Now'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldUpdate) {
        // User agreed to update, so force update
        return await forceUpdateDailies();
      }

      return;
    } catch (e) {
      print('Error showing update dialog: $e');
      return;
    }
  }
}

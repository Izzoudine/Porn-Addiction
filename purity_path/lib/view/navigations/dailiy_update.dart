import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/daily_model.dart';
import 'dailies_manager.dart';

class DailiesUpdater {
  static const String _prefsKey = 'dailies_data';

  static Future<void> checkForUpdatesOnStart() async {
    try {
      await DailiesManager.fetchAndSaveDailiesOnce();
      print("Enter the checkforupdatesonstart");
      
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateTime = prefs.getInt('last_dailies_update_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      print("Time is $lastUpdateTime");
      
      print("Before the date verification");
      if (currentTime - lastUpdateTime > 24 * 60 * 60 * 1000) {
        final updated = await DailiesManager.checkUpdateAndFetchData();
        if (updated) {
          await prefs.setInt('last_dailies_update_time', currentTime);
        }
      } else {
        print("Time has not passed");
      }
    } catch (e) {
      print('Error checking for updates on start: $e');
    }
  }

  
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purity_path/data/models/daily_model.dart';
import 'dart:convert';

class DailiesManager {
  static const String _prefsKey = 'dailies_data';
  static Map<String, List<DailyContent>> _allDailies = {};

  // Load dailies from SharedPreferences
  static Future<void> loadDailies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey) ?? '{}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _allDailies = {};
    for (var section in jsonMap.keys) {
      final List<dynamic> contentJson = jsonMap[section] ?? [];
      print("Our Json is $contentJson");
      _allDailies[section] =
          contentJson.map((json) => DailyContent.fromJson(json)).toList();
    }
  }

  // Get dailies synchronously (from memory)
  static Map<String, List<DailyContent>> getAllDailiesSync() {
    return _allDailies;
  }

  // Check for updates and fetch data from Firestore
  static Future<bool> checkUpdateAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("Enter the checkUpdateAndFetchData");
      final verifySnapshot =
          await FirebaseFirestore.instance.collection('admin').doc('verify data').get();
      final update = prefs.getString("update");
      final updateData = verifySnapshot.data()?['update data'] ?? '';
      print("update is $update");
      print("updatedata is $updateData");
      if (update == updateData) {
        return false;
      }
      print("After the verification in checkUpdateAndFetchData");

      final List<String> sections = ['duas', 'hadiths', 'motivations'];
      Map<String, List<DailyContent>> allData = {};
      print("Entering the for clause");

      for (String section in sections) {
        final querySnapshot =
            await FirebaseFirestore.instance.collection(section).get();
        List<DailyContent> contentList = [];

        for (var doc in querySnapshot.docs) {
          final contentData = doc.data() as Map<String, dynamic>;
          contentList.add(
            DailyContent.fromFirebase(doc.id, contentData, section),
          );
        }

        allData[section] = contentList;
      }

      print("Exiting the for clause");

      final String jsonString = jsonEncode(
        allData.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
      );
      await prefs.setString(_prefsKey, jsonString);
      await prefs.setString("update", updateData);
      print('Saved data: $allData');

      return true;
    } catch (e) {
      print('Error checking update and fetching data: $e');
      return false;
    }
  }

  // Fetch and save dailies once (for first use or cache)
  static Future<void> fetchAndSaveDailiesOnce() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if data exists in SharedPreferences
    if (prefs.containsKey(_prefsKey)) {
      await loadDailies(); // Load existing data into _allDailies
      return;
    }

    // Fetch from Firestore (now using root-level collections)
    final sections = ['duas', 'hadiths', 'motivations'];
    Map<String, List<DailyContent>> allData = {};

    for (var section in sections) {
      List<DailyContent> contentList = [];
      try {
        final querySnapshot =
            await FirebaseFirestore.instance.collection(section).get();
        for (var doc in querySnapshot.docs) {
          final contentData = doc.data() as Map<String, dynamic>;
          contentList.add(
            DailyContent.fromFirebase(doc.id, contentData, section),
          );
        }
        allData[section] = contentList;
        print("The data is ${contentList}");
      } catch (e) {
        print('Error fetching /$section: $e');
      }
    }

    // Save to SharedPreferences
    await prefs.setString(
      _prefsKey,
      jsonEncode(
        allData.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
      ),
    );
    // Update the in-memory data
    _allDailies = allData;
  }

  // Get all dailies (from SharedPreferences)
  static Future<Map<String, List<DailyContent>>> getAllDailies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey) ?? '{}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final Map<String, List<DailyContent>> allData = {};
    for (var section in jsonMap.keys) {
      final List<dynamic> contentJson = jsonMap[section] ?? [];
      allData[section] =
          contentJson.map((json) => DailyContent.fromJson(json)).toList();
    }
    return allData;
  }

  // Get a random daily content for a section
  static Future<DailyContent?> getRandomDailyContent(String section) async {
    final allData = await getAllDailies();
    final sectionData = allData[section];

    if (sectionData == null || sectionData.isEmpty) {
      return null;
    }

    final random = DateTime.now().millisecondsSinceEpoch % sectionData.length;
    return sectionData[random];
  }

  // Get a daily content by ID for a section
  static Future<DailyContent?> getDailyContentById(
    String section,
    String id,
  ) async {
    final allData = await getAllDailies();
    final sectionData = allData[section];

    if (sectionData == null) {
      return null;
    }

    return sectionData.firstWhere(
      (element) => element.id == id,
      orElse: () => throw Exception('Item not found'),
    );
  }

  // Get all dailies in preference format (if needed)
  static Future<Map<String, List<Map<String, String>>>>
      getAllInPreferenceFormat() async {
    final allData = await getAllDailies();
    Map<String, List<Map<String, String>>> result = {};

    allData.forEach((section, contentList) {
      result[section] =
          contentList.map((content) => content.toPreferenceFormat()).toList();
    });

    return result;
  }
}

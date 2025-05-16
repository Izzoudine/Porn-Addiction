import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the DailyContent model
import '../../data/models/daily_model.dart';

class DailiesManager {
  static const String _prefsKey = 'dailies_data';
  static Future<bool> checkUpdateAndFetchData() async {
    try {
      // First check if update is required
      final verifySnapshot =
          await FirebaseFirestore.instance
              .collection('admin')
              .doc('verify data')
              .get();

      final updateData = verifySnapshot.data()?['update data'] ?? false;

      // If update is not required, return false
      if (!updateData) {
        return false;
      }

      // Update is required, so fetch and save data
      final prefs = await SharedPreferences.getInstance();

      final List<String> sections = ['duas', 'hadiths', 'motivations'];
      Map<String, List<DailyContent>> allData = {};

      for (String section in sections) {
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('dailies')
                .doc(section)
                .get();

        final rawData = docSnapshot.data() ?? {};
        List<DailyContent> contentList = [];

        // Each rawData entry is something like "dua1" -> { randomId -> { content fields } }
        rawData.forEach((entryKey, entryValue) {
          // entryKey is "dua1", "dua2", etc.
          // entryValue is a map with a single entry where the key is the random ID

          // Get the random ID and the content
          final randomId = entryValue.keys.first;
          final contentData = Map<String, dynamic>.from(entryValue[randomId]);

          // Add the content to our list
          contentList.add(
            DailyContent.fromFirebase(randomId, contentData, section),
          );
        });

        allData[section] = contentList;
      }

      final String jsonString = jsonEncode(allData);
      await prefs.setString(_prefsKey, jsonString);

      return true;
    } catch (e) {
      print('Error checking update and fetching data: $e');
      return false;
    }
  }

  static Future<void> populateSubcollections() async {
    final Map<String, List<String>> subcollectionIds = {
      'duas': ['dua1', 'dua2', 'dua3'],
      'hadiths': ['hadith1', 'hadith2', 'hadith3'],
      'motivations': ['motivation1', 'motivation2', 'motivation3'],
    };

    for (var section in subcollectionIds.keys) {
      try {
        await FirebaseFirestore.instance
            .collection('dailies')
            .doc('${section}_metadata')
            .set({
              'subcollections': subcollectionIds[section],
            }, SetOptions(merge: true));
        print(
          'Updated subcollections for $section: ${subcollectionIds[section]}',
        );
      } catch (e) {
        print('Error updating $section: $e');
      }
    }
  }

 static Future<void> fetchAndSaveDailiesOnce() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(_prefsKey)) return;

  final sections = ['duas', 'hadiths', 'motivations'];
  Map<String, List<DailyContent>> allData = {};

  for (var section in sections) {
    List<DailyContent> contentList = [];
    try {
      final metadata = await FirebaseFirestore.instance
          .collection('dailies')
          .doc('${section}_metadata')
          .get();

      if (!metadata.exists) {
        print('No metadata for $section');
        continue;
      }

      final subcollections = List<String>.from(metadata.data()?['subcollections'] ?? []);
      print('Subcollections for $section: $subcollections');

      for (var subId in subcollections) {
        final docs = await FirebaseFirestore.instance
            .collection('dailies')
            .doc(section)
            .collection(subId)
            .get();
        print('Found ${docs.docs.length} documents in $subId');

        for (var doc in docs.docs) {
          contentList.add(
            DailyContent.fromFirebase(
              doc.id,
              Map<String, dynamic>.from(doc.data()),
              section,
            ),
          );
        }
      }

      allData[section] = contentList;
    } catch (e) {
      print('Error fetching /dailies/$section: $e');
    }
  }

  await prefs.setString(_prefsKey, jsonEncode(allData.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()))));
  print('Saved data: $allData');
}
  // Retrieve all data from SharedPreferences
static Future<Map<String, List<DailyContent>>> getAllDailies() async {
  final prefs =await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_prefsKey) ?? '{}';
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  final Map<String, List<DailyContent>> allData = {};
  for (var section in jsonMap.keys) {
    final List<dynamic> contentJson = jsonMap[section] ?? [];
    allData[section] = contentJson
        .map((json) => DailyContent.fromJson(json))
        .toList();
  }
  return allData;
}

  // Get a random item from a specific section
  static Future<DailyContent?> getRandomDailyContent(String section) async {
    final allData = await getAllDailies();
    final sectionData = allData[section];

    if (sectionData == null || sectionData.isEmpty) {
      return null;
    }

    // Get a random item
    final random = DateTime.now().millisecondsSinceEpoch % sectionData.length;
    return sectionData[random];
  }

  // Get a specific item by ID and section
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

  // Get all data in the preference format (a,b,c,d,e)
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purity_path/data/models/daily_model.dart';
import 'dart:convert';

class DailiesManager {
  static const String _prefsKey = 'dailies_data';
  static Map<String, List<DailyContent>> _allDailies = {};
  static Future<void> loadDailies() async {
    clearDailiesCache();

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

  // Synchronous method to access preloaded data
  static Map<String, List<DailyContent>> getAllDailiesSync() {
    return _allDailies;
  }

  static Future<bool> checkUpdateAndFetchData() async {
    try {
      final verifySnapshot =
          await FirebaseFirestore.instance
              .collection('admin')
              .doc('verify data')
              .get();

      final updateData = verifySnapshot.data()?['update data'] ?? false;

      if (!updateData) {
        return false;
      }

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

        rawData.forEach((entryKey, entryValue) {
          final randomId = entryValue.keys.first;
          final contentData = Map<String, dynamic>.from(entryValue[randomId]);
          contentList.add(
            DailyContent.fromFirebase(randomId, contentData, section),
          );
        });

        allData[section] = contentList;
      }

      final String jsonString = jsonEncode(
        allData.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
      );
      await prefs.setString(_prefsKey, jsonString);
      print('Saved data: $allData');

      return true;
    } catch (e) {
      print('Error checking update and fetching data: $e');
      return false;
    }
  }

  /*
  static Future<void> populateSubcollections() async {
    final Map<String, Map<String, Map<String, Map<String, dynamic>>>> data = {
      'duas': {
        'dua1': {
          'autoId1': {
            'Name': 'Dua for Strength',
            'Content': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
            'Specific': 'O Allah, I ask You for firmness in the matter and determination upon guidance.',
            'Description': 'This dua is particularly beneficial when you are facing temptations. It asks Allah for firmness in your affairs and determination to stay on the right path. Recite it when you feel your resolve weakening.'
          },
        },
        'dua2': {
          'autoId2': {
            'Name': 'Dua for Protection',
            'Content': 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
            'Specific': 'O Allah, suffice me with what You have allowed instead of what You have forbidden, and make me independent of all others besides You.',
            'Description': 'This powerful dua asks Allah to make the halal (permissible) things sufficient for you so that you avoid the haram (forbidden). It\'s especially helpful when struggling with addictive behaviors.'
          },
        },
        'dua3': {
          'autoId3': {
            'Name': 'Dua for Forgiveness',
            'Content': 'رَبِّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي، وَإِسْرَافِي فِي أَمْرِي كُلِّهِ، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
            'Specific': 'O my Lord! Forgive my sins, my ignorance, my immoderation in my affairs, and all that You know better than I do.',
            'Description': 'This comprehensive dua for forgiveness acknowledges our human weaknesses and asks Allah to forgive all our shortcomings. It\'s particularly beneficial after a relapse to help you get back on track.'
          },
        },
      },
      'hadiths': {
        'hadith1': {
          'autoId1': {
            'Name': 'On Lowering the Gaze',
            'Content': 'The Prophet ﷺ said: "Do not follow a glance with another, for you will be forgiven for the first, but not for the second."',
            'Specific': 'Reported by Ahmad, Abu Dawud and At-Tirmidhi',
            'Description': 'This hadith teaches us about the importance of controlling our gaze. The first accidental glance at something inappropriate may be forgiven, but deliberately looking again is sinful. This hadith is particularly relevant for overcoming visual temptations that often lead to pornography addiction.'
          },
        },
        'hadith2': {
          'autoId2': {
            'Name': 'On Purity',
            'Content': 'The Prophet ﷺ said: "Verily, Allah is pure and loves purity."',
            'Specific': 'Sahih Muslim',
            'Description': 'This hadith reminds us that Allah loves purity in all its forms - physical, mental, and spiritual. By striving for purity in our thoughts and actions, we align ourselves with what Allah loves. This can be a powerful motivation in your journey to overcome addiction.'
          },
        },
        'hadith3': {
          'autoId3': {
            'Name': 'On Self-Control',
            'Content': 'The Prophet ﷺ said: "The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry."',
            'Specific': 'Sahih Al-Bukhari',
            'Description': 'This hadith redefines strength as self-control rather than physical power. It teaches us that true strength lies in controlling our desires and emotions, not in giving in to them. Apply this wisdom to your struggle with addiction by recognizing that resisting urges is a sign of true strength.'
          },
        },
      },
      'motivations': {
        'motivation1': {
          'autoId1': {
            'Name': 'The Neuroscience of Addiction',
            'Content': 'Learn how pornography affects your brain chemistry and creates addictive patterns.',
            'Specific': 'Tap to read more',
            'Description': 'Pornography addiction works similarly to substance addiction in the brain. When you view pornography, your brain releases dopamine, creating feelings of pleasure. With repeated exposure, your brain requires more explicit content to achieve the same dopamine release, leading to escalation.\n\nThis creates neural pathways that strengthen with each viewing, making the habit more difficult to break. However, the brain has "neuroplasticity" - the ability to form new neural connections. By abstaining from pornography, these pathways begin to weaken, while new, healthier pathways strengthen through positive activities.\n\nUnderstanding this process can help you recognize that your struggle is not a moral failing but a neurological challenge that can be overcome with time and consistent effort.'
          },
        },
        'motivation2': {
          'autoId2': {
            'Name': 'Islamic Perspective on Addiction',
            'Content': 'Understanding addiction through the lens of Islamic teachings and principles.',
            'Specific': 'Tap to read more',
            'Description': 'Islam recognizes human weakness and the potential for addiction, but also provides a framework for overcoming it. The Quran states: "Allah does not burden a soul beyond what it can bear" (2:286), reminding us that every challenge we face is within our capacity to overcome.\n\nAddiction is often related to the concept of "nafs" (lower self) that commands to evil (Quran 12:53). Through spiritual discipline, one can progress to the "nafs al-lawwamah" (the self-reproaching soul) and eventually to "nafs al-mutma\'innah" (the soul at peace).\n\nIslamic principles that help overcome addiction include: regular prayer (salah) which provides structure and mindfulness, fasting (sawm) which builds self-control, remembrance of Allah (dhikr) which provides spiritual strength, and community support (ummah) which provides accountability and encouragement.'
          },
        },
        'motivation3': {
          'autoId3': {
            'Name': 'Practical Steps to Break Free',
            'Content': 'A comprehensive guide with actionable steps to overcome pornography addiction.',
            'Specific': 'Tap to read more',
            'Description': '1. Install blocking software on all your devices to prevent access to inappropriate content.\n\n2. Identify your triggers (boredom, stress, loneliness) and develop specific strategies for each one.\n\n3. Replace the habit with healthy alternatives: exercise, reading, social activities, or creative pursuits.\n\n4. Practice mindfulness and meditation to become more aware of your thoughts and urges without acting on them.\n\n5. Maintain a journal to track your progress, identify patterns, and celebrate victories.\n\n6. Establish accountability with a trusted friend or mentor who can support your journey.\n\n7. Create a "emergency plan" for moments of strong temptation: specific actions to take, people to call, or places to go.\n\n8. Be patient with yourself and recognize that recovery is a process with ups and downs.'
          },
        },
      },
    };

    for (var section in data.keys) {
      try {
        await FirebaseFirestore.instance
            .collection('dailies')
            .doc('${section}_metadata')
            .set(
              {'subcollections': data[section].keys.toList()},
              SetOptions(merge: true),
            );

        await FirebaseFirestore.instance
            .collection('dailies')
            .doc(section)
            .set(data[section], SetOptions(merge: true));

        print('Updated $section with subcollections: ${data[section].keys}');
      } catch (e) {
        print('Error updating $section: $e');
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('admin')
          .doc('verify data')
          .set({'update data': true}, SetOptions(merge: true));
      print('Set update data to true');
    } catch (e) {
      print('Error setting update data: $e');
    }
  }
*/
  static Future<void> fetchAndSaveDailiesOnce() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if data exists in SharedPreferences
    if (prefs.containsKey(_prefsKey)) {
      await loadDailies(); // Load existing data into _allDailies
      return;
    }
    

    // Fetch from Firestore (or your data source)
    final sections = ['duas', 'hadiths', 'motivations'];
    Map<String, List<DailyContent>> allData = {};

    for (var section in sections) {
      List<DailyContent> contentList = [];
      try {
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('dailies')
                .doc(section)
                .get();
        final rawData = docSnapshot.data() ?? {};
        rawData.forEach((entryKey, entryValue) {
          final randomId = entryValue.keys.first;
          final contentData = Map<String, dynamic>.from(entryValue[randomId]);
          contentList.add(
            DailyContent.fromFirebase(randomId, contentData, section),
          );
        });
        allData[section] = contentList;
        print("The data is ${contentList}");
      } catch (e) {
        print('Error fetching /dailies/$section: $e');
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

  static Future<void> clearDailiesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    print('Dailies cache cleared');
  }

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

  static Future<DailyContent?> getRandomDailyContent(String section) async {
    final allData = await getAllDailies();
    final sectionData = allData[section];

    if (sectionData == null || sectionData.isEmpty) {
      return null;
    }

    final random = DateTime.now().millisecondsSinceEpoch % sectionData.length;
    return sectionData[random];
  }

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

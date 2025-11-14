import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purity_path/data/services/permissions_service.dart';
import 'package:purity_path/data/services/phase_manager.dart';
import 'package:purity_path/data/models/reduction_phase.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'acceptance.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int contentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  String today = '';
  Timer? _autoScrollTimer;
  bool _hasStartedJourney = false;
  
  // Phase tracking
  ReductionPhase? _currentPhase;

  List<Map<String, String>> dailyContent = [
    {
      'type': 'Dua of the Day',
      'content': "O Allah, I seek refuge in You from evil deeds and desires.",
      'icon': '🤲',
    },
    {
      'type': 'Hadith of the Day',
      'content':
          "The Prophet ﷺ said: 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.'",
      'icon': '📚',
    },
    {
      'type': 'Motivation of the Day',
      'content': "Every time you resist temptation, you become stronger.",
      'icon': '💪',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _checkAndUpdateDailyContent();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (contentIndex < 2) {
          _pageController.animateToPage(
            contentIndex + 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _navigateToPermissions() async {
    final result = await Navigator.pushNamed(context, RoutesName.permissions);
    setState(() {}); // Refresh UI to recheck permissions
    if (result == true) {
    }
  }

  void start() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {'startDate': FieldValue.serverTimestamp()},
      );
      final database = FirebaseDatabase.instance.ref();
      await database.child('users/${user.uid}').update({
        'startDate': ServerValue.timestamp,
      });
    }
  }

  Future<bool> checkPermission() async {
    try {
      final permitAccess =
          await PermissionService.isAccessibilityServiceEnabled();
      final permitNotifications =
          await PermissionService.isNotificationPermissionGranted();
      final permitBattery =
          await PermissionService.isIgnoringBatteryOptimizations();
      return permitAccess && permitNotifications && permitBattery;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle if needed
  }

  Future<void> _checkAndUpdateDailyContent() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getString('lastContentUpdate') ?? '';
    if (lastUpdated != today) {
      _updateDailyContent();
      await prefs.setString('lastContentUpdate', today);
    }
    _hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;
  }

  void _updateDailyContent() {
    final random = Random();
    List<String> duas = [
      "O Allah, I seek refuge in You from evil deeds and desires.",
      "My Lord, forgive me and accept my repentance. You are the Ever-Relenting, the Most Merciful.",
      "O Allah, purify my heart and protect my private parts.",
      "O Allah, make me among those who return to You in repentance and those who purify themselves.",
      "O Allah, I seek Your help in controlling my desires and strengthening my faith.",
    ];
    List<String> hadiths = [
      "The Prophet ﷺ said: 'Do not follow a glance with another, for you will be forgiven for the first, but not for the second.'",
      "The Prophet ﷺ said: 'Verily, Allah is pure and loves purity.'",
      "The Prophet ﷺ said: 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.'",
      "The Prophet ﷺ said: 'One who repents from sin is like one who has not sinned.'",
      "The Prophet ﷺ said: 'Part of the perfection of one's Islam is his leaving that which does not concern him.'",
    ];
    List<String> motivations = [
      "Every time you resist temptation, you become stronger.",
      "Your struggle is known to Allah, and He appreciates your efforts.",
      "Every day of purity is a victory worth celebrating.",
      "Remember, Allah does not burden a soul beyond what it can bear.",
      "Small steps lead to big changes. Be patient with yourself.",
    ];
    setState(() {
      dailyContent[0]['content'] = duas[random.nextInt(duas.length)];
      dailyContent[1]['content'] = hadiths[random.nextInt(hadiths.length)];
      dailyContent[2]['content'] =
          motivations[random.nextInt(motivations.length)];
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;
    
    // Load current phase
    final currentPhase = await PhaseManager.getCurrentPhase();
    
    setState(() {
      _currentPhase = currentPhase;
    });
  }

  void _navigateToAcceptancePage() async {
    start();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AcceptancePage()),
    );
    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasStartedJourney', true);
      setState(() {
        _hasStartedJourney = true;
      });
      await _loadData(); // Reload phase data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<bool>(
              future: checkPermission(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bool allPermissionsGranted = snapshot.data ?? false;
                if (!allPermissionsGranted) {
                  return _buildPermissionNotification(context);
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NoFap Islam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: dailyContent.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    contentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  List<List<Color>> colorSchemes = [
                                    [
                                      const Color(0xFF2196F3),
                                      const Color(0xFF1976D2),
                                    ],
                                    [
                                      const Color(0xFF42A5F5),
                                      const Color(0xFF1E88E5),
                                    ],
                                    [
                                      const Color(0xFF64B5F6),
                                      const Color(0xFF2979FF),
                                    ],
                                  ];
                                  return AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: colorSchemes[index],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  dailyContent[index]['icon'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dailyContent[index]['type'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                child: Text(
                                                  dailyContent[index]['content'] ??
                                                      '',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (contentIndex > 0) {
                                      _pageController.animateToPage(
                                        contentIndex - 1,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _pageController.animateToPage(
                                        2,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                                ...List.generate(
                                  dailyContent.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          contentIndex == index
                                              ? const Color(0xFF2196F3)
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (contentIndex < 2) {
                                      _pageController.animateToPage(
                                        contentIndex + 1,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _pageController.animateToPage(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2196F3,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shield,
                                      color: Color(0xFF2196F3),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Supreme test",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      Text(
                                        "Your digital guardian",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _hasStartedJourney
                                  ? Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2196F3,
                                      ).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF2196F3,
                                        ).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Your Current Phase",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2196F3),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        if (_currentPhase != null) ...[
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  _getPhaseColor(),
                                                  _getPhaseColor().withOpacity(0.7),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getPhaseColor().withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Icon(
                                                        _getPhaseIcon(),
                                                        color: Colors.white,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Phase ${_currentPhase!.phaseNumber}',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 24,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Week ${_currentPhase!.weekNumber}',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.9),
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                                Container(
                                                  padding: const EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      if (_currentPhase!.durationLimit != null)
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Max Duration:',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${_currentPhase!.durationLimit} min',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (_currentPhase!.durationLimit != null && _currentPhase!.frequencyLimit != null)
                                                        const SizedBox(height: 8),
                                                      if (_currentPhase!.frequencyLimit != null)
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Max Frequency:',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${_currentPhase!.frequencyLimit}/week',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (_currentPhase!.spacingLimit != null)
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Spacing:',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              _currentPhase!.spacingLimit!,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          const Text(
                                            'Complete the questionnaire to see your phase',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                  : Text(
                                    "Begin your journey to digital purity and self-control. Our advanced protection system will help you stay on track.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                              const SizedBox(height: 20),
                              
                              _hasStartedJourney
                                  ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2196F3,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF2196F3,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Your Journey Has Started",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed: _navigateToAcceptancePage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      "Begin Your Journey",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionNotification(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade800,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissions Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      'Some permissions are missing for full protection.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _navigateToPermissions,
            icon: const Icon(Icons.settings, size: 20),
            label: const Text('Grant Permissions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPhaseColor() {
    if (_currentPhase == null) return const Color(0xFF2196F3);
    
    switch (_currentPhase!.phaseType) {
      case 'duration':
        return const Color(0xFF2196F3); // Blue
      case 'frequency':
        return const Color(0xFF9C27B0); // Purple
      case 'spacing':
        return const Color(0xFFFF9800); // Orange
      case 'complete':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF2196F3);
    }
  }
  
  IconData _getPhaseIcon() {
    if (_currentPhase == null) return Icons.flag;
    
    switch (_currentPhase!.phaseType) {
      case 'duration':
        return Icons.timer;
      case 'frequency':
        return Icons.event_repeat;
      case 'spacing':
        return Icons.calendar_today;
      case 'complete':
        return Icons.check_circle;
      default:
        return Icons.flag;
    }
  }
}

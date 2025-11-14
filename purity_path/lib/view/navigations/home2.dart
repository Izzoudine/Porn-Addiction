import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purity_path/data/services/permissions_service.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purity_path/data/services/phase_manager.dart';
import 'package:purity_path/data/models/reduction_phase.dart';
import 'acceptance.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int contentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  String today = '';
  Timer? _autoScrollTimer;
  bool _hasStartedJourney = false;
  Future<bool>? _permissionFuture;
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
    _permissionFuture = checkPermission();
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

    // Load current phase
    _loadCurrentPhase();
  }

  Future<bool> checkPermission() async {
    try {
      final permitAccess =
          await PermissionService.isAccessibilityServiceEnabled();
      final permitNotifications =
          await PermissionService.isNotificationPermissionGranted();
      final permitAdmin =
          await PermissionService.isDeviceAdminPermissionGranted();
      final permitOverlay =
          await PermissionService.isOverlayPermissionGranted();
      return permitAccess &&
          permitNotifications &&
          permitAdmin &&
          permitOverlay;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  void _navigateToPermissions() async {
    final result = await Navigator.pushNamed(context, RoutesName.permissions);
    setState(() {}); // Refresh UI to recheck permissions
    if (result == true) {}
  }

  Future<void> _loadCurrentPhase() async {
    final phase = await PhaseManager.getCurrentPhase();
    if (mounted) {
      setState(() {
        _currentPhase = phase;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndUpdateDailyContent() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getString('lastContentUpdate') ?? '';

    if (lastUpdated != today) {
      _updateDailyContent();
      await prefs.setString('lastContentUpdate', today);
    }

    // Check if journey has been started
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

    setState(() {});
  }

  void _navigateToAcceptancePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AcceptancePage()),
    );

    // Check if journey was started from the acceptance page
    if (result == true) {
      setState(() {
        _hasStartedJourney = true;
      });
      _loadCurrentPhase();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<bool>(
              future: _permissionFuture,
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

            // App title and emergency button
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

            // Main content with balanced distribution
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Daily content carousel - GROWABLE based on content
                      Container(
                        // No fixed height - will grow based on content
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
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.25, // Responsive height
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: 3,
                                onPageChanged: (index) {
                                  setState(() {
                                    contentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  // New color scheme based on the image
                                  List<List<Color>> colorSchemes = [
                                    [
                                      const Color(0xFF2196F3),
                                      const Color(0xFF1976D2),
                                    ], // Blue scheme
                                    [
                                      const Color(0xFF42A5F5),
                                      const Color(0xFF1E88E5),
                                    ], // Lighter blue
                                    [
                                      const Color(0xFF64B5F6),
                                      const Color(0xFF2979FF),
                                    ], // Even lighter blue
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
                                            // Header with icon and type
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

                                            // Content with scrolling capability
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
                                  3,
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

                      // Second container with blue colors
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
                                  ? _buildPhaseDisplay()
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

  Widget _buildPhaseDisplay() {
    if (_currentPhase == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Loading your phase...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Determine colors based on phase type
    List<Color> gradientColors;
    IconData phaseIcon;

    switch (_currentPhase!.phaseType) {
      case 'duration':
        gradientColors = [const Color(0xFF2196F3), const Color(0xFF1565C0)];
        phaseIcon = Icons.timer_outlined;
        break;
      case 'frequency':
        gradientColors = [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)];
        phaseIcon = Icons.repeat;
        break;
      case 'spacing':
        gradientColors = [const Color(0xFFFF9800), const Color(0xFFE65100)];
        phaseIcon = Icons.calendar_today;
        break;
      case 'complete':
        gradientColors = [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
        phaseIcon = Icons.check_circle_outline;
        break;
      default:
        gradientColors = [const Color(0xFF2196F3), const Color(0xFF1565C0)];
        phaseIcon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase icon and number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(phaseIcon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase ${_currentPhase!.phaseNumber}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Week ${_currentPhase!.weekNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phase description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentPhase!.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phase limits
          if (_currentPhase!.phaseType != 'complete') ...[
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            const Text(
              'Current Limits:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Duration limit
            if (_currentPhase!.durationLimit != null &&
                _currentPhase!.durationLimit! > 0)
              _buildLimitItem(
                Icons.access_time,
                'Max Duration',
                '${_currentPhase!.durationLimit} minutes per session',
              ),

            // Frequency limit
            if (_currentPhase!.frequencyLimit != null &&
                _currentPhase!.frequencyLimit! > 0)
              _buildLimitItem(
                Icons.repeat,
                'Max Frequency',
                '${_currentPhase!.frequencyLimit} time${_currentPhase!.frequencyLimit! > 1 ? 's' : ''} per week',
              ),

            // Spacing limit
            if (_currentPhase!.spacingLimit != null)
              _buildLimitItem(
                Icons.calendar_today,
                'Spacing',
                _getSpacingText(_currentPhase!.spacingLimit!),
              ),
          ] else ...[
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have achieved complete control! 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLimitItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSpacingText(String spacing) {
    switch (spacing) {
      case 'biweekly':
        return 'Once every 2 weeks';
      case 'monthly':
        return 'Once per month';
      case 'complete_control':
        return 'Complete control achieved';
      default:
        return spacing;
    }
  }
}

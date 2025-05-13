import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int cleanDays = 0;
  int cleanHours = 0;
  int cleanMinutes = 0;
  int cleanSeconds = 0;
  int contentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  String today = '';
  Timer? _autoScrollTimer;
  Timer? _countUpdateTimer;
  DateTime? _lastRelapseDate;
  bool _hasStartedJourney = false;
  
  List<Map<String, String>> dailyContent = [
    {
      'type': 'Dua of the Day',
      'content': "O Allah, I seek refuge in You from evil deeds and desires.",
      'icon': '🤲'
    },
    {
      'type': 'Hadith of the Day',
      'content': "The Prophet ﷺ said: 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.'",
      'icon': '📚'
    },
    {
      'type': 'Motivation of the Day',
      'content': "Every time you resist temptation, you become stronger.",
      'icon': '💪'
    },
  ];

  @override
  void initState() {
    super.initState();
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
    
    _countUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastRelapseDate != null) {
        _updateCleanTimeCounter();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    _countUpdateTimer?.cancel();
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
      "O Allah, I seek Your help in controlling my desires and strengthening my faith."
    ];
    
    List<String> hadiths = [
      "The Prophet ﷺ said: 'Do not follow a glance with another, for you will be forgiven for the first, but not for the second.'",
      "The Prophet ﷺ said: 'Verily, Allah is pure and loves purity.'",
      "The Prophet ﷺ said: 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.'",
      "The Prophet ﷺ said: 'One who repents from sin is like one who has not sinned.'",
      "The Prophet ﷺ said: 'Part of the perfection of one's Islam is his leaving that which does not concern him.'"
    ];
    
    List<String> motivations = [
      "Every time you resist temptation, you become stronger.",
      "Your struggle is known to Allah, and He appreciates your efforts.",
      "Every day of purity is a victory worth celebrating.",
      "Remember, Allah does not burden a soul beyond what it can bear.",
      "Small steps lead to big changes. Be patient with yourself."
    ];
    
    setState(() {
      dailyContent[0]['content'] = duas[random.nextInt(duas.length)];
      dailyContent[1]['content'] = hadiths[random.nextInt(hadiths.length)];
      dailyContent[2]['content'] = motivations[random.nextInt(motivations.length)];
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRelapse = prefs.getString('lastRelapse') ?? DateTime.now().toIso8601String();
    final lastRelapseDate = DateTime.parse(lastRelapse);
    _hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;
    
    setState(() {
      _lastRelapseDate = lastRelapseDate;
    });
    
    _updateCleanTimeCounter();
  }
  
  void _updateCleanTimeCounter() {
    if (_lastRelapseDate == null) return;
    
    final now = DateTime.now();
    final difference = now.difference(_lastRelapseDate!);
    
    setState(() {
      cleanDays = difference.inDays;
      cleanHours = difference.inHours % 24;
      cleanMinutes = difference.inMinutes % 60;
      cleanSeconds = difference.inSeconds % 60;
    });
  }

  void _logRelapse() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('lastRelapse', now.toIso8601String());
    
    List<String> history = prefs.getStringList('relapseHistory') ?? [];
    history.add(now.toIso8601String());
    await prefs.setStringList('relapseHistory', history);
    
    setState(() {
      _lastRelapseDate = now;
      cleanDays = 0;
      cleanHours = 0;
      cleanMinutes = 0;
      cleanSeconds = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relapse logged. Stay strong, every new day is a fresh start.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startIrreversibleJourney() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Begin Your Irreversible Journey',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You are about to embark on a sacred journey of self-mastery and spiritual growth. This decision marks a permanent commitment to purity and self-control.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Are you ready to make this covenant with yourself and with Allah?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Not Yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasStartedJourney', true);
                
                // Reset counter to this moment
                final now = DateTime.now();
                await prefs.setString('lastRelapse', now.toIso8601String());
                
                setState(() {
                  _hasStartedJourney = true;
                  _lastRelapseDate = now;
                  cleanDays = 0;
                  cleanHours = 0;
                  cleanMinutes = 0;
                  cleanSeconds = 0;
                });
                
                Navigator.of(context).pop();
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your journey has begun. May Allah grant you strength.'),
                    backgroundColor: Colors.teal,
                    duration: Duration(seconds: 5),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('I AM READY'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade50, Colors.white],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Emergency Support',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'You\'re experiencing an urge right now. This is temporary and will pass. Here are some immediate actions you can take:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
                  Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                  child: const Text(
                    'I FEEL BETTER NOW',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: _showEmergencyModal,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content with balanced distribution
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Daily content carousel
                    Expanded(
                      flex: 1,
                      child: Container(
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
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: 3,
                                onPageChanged: (index) {
                                  setState(() {
                                    contentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: index == 0 
                                            ? [Colors.teal.shade300, Colors.teal.shade600]
                                            : index == 1 
                                              ? [Colors.blue.shade300, Colors.blue.shade600]
                                              : [Colors.amber.shade300, Colors.amber.shade600],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            // Header with icon and type
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  dailyContent[index]['icon'] ?? '',
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dailyContent[index]['type'] ?? '',
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
                                                physics: const BouncingScrollPhysics(),
                                                child: Text(
                                                  dailyContent[index]['content'] ?? '',
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
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (contentIndex > 0) {
                                      _pageController.animateToPage(
                                        contentIndex - 1,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _pageController.animateToPage(
                                        2,
                                        duration: const Duration(milliseconds: 300),
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
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: contentIndex == index ? Colors.teal : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (contentIndex < 2) {
                                      _pageController.animateToPage(
                                        contentIndex + 1,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _pageController.animateToPage(
                                        0,
                                        duration: const Duration(milliseconds: 300),
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
                    ),
                    
                    // Irreversible Journey Button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: _hasStartedJourney 
                      ? Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'YOUR JOURNEY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildTimeDigit(cleanDays.toString(), 'DAYS'),
                                    _buildTimeSeparator(),
                                    _buildTimeDigit(cleanHours.toString().padLeft(2, '0'), 'HOURS'),
                                    _buildTimeSeparator(),
                                    _buildTimeDigit(cleanMinutes.toString().padLeft(2, '0'), 'MINS'),
                                    _buildTimeSeparator(),
                                    _buildTimeDigit(cleanSeconds.toString().padLeft(2, '0'), 'SECS'),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: const Text('Log a Relapse?'),
                                        content: const Text(
                                          'Everyone stumbles on their journey. Honesty is the first step toward growth. If you\'ve relapsed, logging it will reset your counter.',
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('CANCEL'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _logRelapse();
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('LOG RELAPSE'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.restart_alt,
                                    color: Colors.white70,
                                  ),
                                  label: const Text(
                                    'Log a Relapse',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : GestureDetector(
                        onTap: _startIrreversibleJourney,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.shade400,
                                Colors.deepPurple.shade800,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.transparent,
                              onTap: _startIrreversibleJourney,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Subtle background pattern
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: JourneyBackgroundPainter(),
                                    ),
                                  ),
                                  // Inner shadow for depth
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: RadialGradient(
                                          center: Alignment.center,
                                          radius: 1.2,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.rocket_launch,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "BEGIN YOUR IRREVERSIBLE JOURNEY",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Take the first step toward transformation",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Glowing effect at the edges
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }
  
  Widget _buildTimeDigit(String digit, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            digit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Background painter for the journey button
class JourneyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double maxRadius = size.width * 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw circles
    for (int i = 1; i <= 5; i++) {
      final radius = maxRadius * (i / 5);
      canvas.drawCircle(center, radius, paint);
    }
    
    // Draw some random stars/dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    final random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
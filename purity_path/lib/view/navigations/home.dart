import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// Constants for styling and configuration
class AppConstants {
  static const primaryColor = Colors.indigo;
  static const secondaryColor = Colors.blue;
  static const cardPadding = EdgeInsets.all(24);
  static const borderRadius = 24.0;
  static const shadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 20,
    offset: Offset(0, 4),
  );
}

/// Daily content data
const List<Map<String, dynamic>> dailyContent = [
  {
    'type': 'Dua',
    'content': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'translation': 'Our Lord, give us good in this world and good in the Hereafter and protect us from the torment of the Fire.'
  },
  {
    'type': 'Motivation',
    'content': 'Every time you resist temptation, you become stronger. Your struggle today is developing the strength you need for tomorrow.',
  },
  {
    'type': 'Hadith',
    'content': 'The Messenger of Allah (ﷺ) said, "The eyes commit zina, and their zina is looking at what is forbidden."',
    'source': 'Sahih al-Bukhari'
  },
];

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  DateTime _lastRelapse = DateTime.now().subtract(const Duration(days: 7));
  int _dailyContentIndex = 0;

  /// Cycles to the next daily content item
  void _cycleContent() {
    setState(() {
      _dailyContentIndex = (_dailyContentIndex + 1) % dailyContent.length;
    });
  }

  /// Resets the relapse counter
  void _resetCounter() {
    setState(() {
      _lastRelapse = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysDifference = DateTime.now().difference(_lastRelapse).inDays;
    final content = dailyContent[_dailyContentIndex];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),

              const SizedBox(height: 20),
              _DailyContentCard(content: content, onTap: _cycleContent),
              const SizedBox(height: 32),
              StreakCounter(days: daysDifference),
              const SizedBox(height: 24),
              _ActionButtons(onReset: () => _showRelapseDialog(context)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmergencySupportModal(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Emergency Support',
        child: const Icon(Icons.health_and_safety_outlined),
      ),
    );
  }

  /// Shows dialog to confirm counter reset
  void _showRelapseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: const Text('Reset Your Counter'),
        content: const Text(
          'Are you sure you want to reset your counter? Your history will be saved for insights.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _resetCounter();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Counter has been reset. Each moment is a new beginning.'),
                  backgroundColor: AppConstants.primaryColor.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor.shade100,
              foregroundColor: AppConstants.primaryColor.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  /// Shows emergency support modal
  void _showEmergencySupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmergencySupportModal(),
    );
  }
}

/// Header widget with app branding
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.shade400,
                    AppConstants.secondaryColor.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'PP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Purity Path',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor.shade700,
              ),
            ),
          ],
        ),
        Text(
          'Bismillah',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}



class StreakCounter extends StatefulWidget {
  final int days;
  final int milestoneDays;
  final Color primaryColor;
  final Color secondaryColor;
  
  const StreakCounter({
    Key? key,
    required this.days,
    this.milestoneDays = 30,
    this.primaryColor = const Color(0xFF4E7DFF),
    this.secondaryColor = const Color(0xFF6E9EFF),
  }) : super(key: key);

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _countAnimation = Tween<double>(
      begin: 0,
      end: widget.days.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.days % widget.milestoneDays) / widget.milestoneDays,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));
    
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(StreakCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) {
      _countAnimation = Tween<double>(
        begin: oldWidget.days.toDouble(),
        end: widget.days.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));
      
      _progressAnimation = Tween<double>(
        begin: (oldWidget.days % widget.milestoneDays) / widget.milestoneDays,
        end: (widget.days % widget.milestoneDays) / widget.milestoneDays,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ));
      
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDaysRemainingText() {
    final daysRemaining = widget.milestoneDays - (widget.days % widget.milestoneDays);
    if (daysRemaining == widget.milestoneDays) {
      return 'Milestone achieved!';
    } else {
      return 'Next milestone: $daysRemaining day${daysRemaining != 1 ? 's' : ''} to go';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primaryColor.withOpacity(0.1),
            widget.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStreakHeader(),
          const SizedBox(height: 4),
          _buildDaysCounter(),
          const SizedBox(height: 4),
          _buildClarityText(),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 8),
          _buildMilestoneText(),
        ],
      ),
    );
  }

  Widget _buildStreakHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_fire_department,
          color: widget.primaryColor,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          'CURRENT STREAK',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.primaryColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysCounter() {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Text(
                '${_countAnimation.value.toInt()}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor.withOpacity(0.9),
                  height: 1.1,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClarityText() {
    return Text(
      'day${widget.days != 1 ? 's' : ''} of clarity',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * _progressAnimation.value;
                      return Container(
                        height: 10,
                        width: width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.primaryColor,
                              widget.secondaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if ((widget.days % widget.milestoneDays) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '${widget.milestoneDays}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMilestoneText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Text(
          _getDaysRemainingText(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}


class _DailyContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onTap;

  const _DailyContentCard({required this.content, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppConstants.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [AppConstants.shadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    content['type'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor.shade700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppConstants.primaryColor.shade300,
                  ),
                  onPressed: onTap,
                  iconSize: 20,
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              content['content'],
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
              textAlign: content['type'] == 'Dua' ? TextAlign.right : TextAlign.left,
            ),
            if (content.containsKey('translation')) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  content['translation'],
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (content.containsKey('source')) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      content['source'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Goals card widget
class _GoalsCard extends StatelessWidget {
  final int days;

  const _GoalsCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [AppConstants.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: AppConstants.primaryColor.shade400),
              const SizedBox(width: 12),
              Text(
                'Your Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _GoalProgressBar(goalText: '7 days clean', progress: days / 7),
          const SizedBox(height: 16),
          _GoalProgressBar(goalText: '30 days clean', progress: days / 30),
          const SizedBox(height: 16),
          _GoalProgressBar(goalText: '90 days clean', progress: days / 90),
        ],
      ),
    );
  }
}

/// Goal progress bar widget
class _GoalProgressBar extends StatelessWidget {
  final String goalText;
  final double progress;

  const _GoalProgressBar({required this.goalText, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;
    final progressColor = isComplete ? Colors.green : AppConstants.primaryColor.shade400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            isComplete
                ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                : Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 10),
            Text(
              goalText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isComplete ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * 0.8 * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isComplete ? 'Completed! Keep going!' : '${(progress * 100).toInt()}% completed',
          style: TextStyle(
            fontSize: 12,
            color: isComplete ? Colors.green : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Action buttons widget
class _ActionButtons extends StatelessWidget {
  final VoidCallback onReset;

  const _ActionButtons({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Reset Counter',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

/// Emergency support modal widget
class _EmergencySupportModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.healing_rounded,
                    color: AppConstants.primaryColor.shade400,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Mindful Moment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _EmergencyCard(
                    title: 'Breathe',
                    content: 'Take 5 deep breaths. Inhale for 4 seconds, hold for a moment, and exhale for 6 seconds.',
                    icon: Icons.air_rounded,
                    color: AppConstants.secondaryColor,
                  ),
                  _EmergencyCard(
                    title: 'Remember Your Purpose',
                    content: 'Allah is with the patient. Remember why you started this journey and how far you\'ve come.',
                    icon: Icons.favorite_rounded,
                    color: AppConstants.primaryColor,
                  ),
                  _EmergencyCard(
                    title: 'Quick Dua',
                    content: 'اللهم إني أسألك العافية في الدنيا والآخرة\n\n"O Allah, I ask You for well-being in this world and the Hereafter."',
                    icon: Icons.auto_stories_rounded,
                    color: Colors.teal,
                  ),
                  _EmergencyCard(
                    title: 'Change Your Environment',
                    content: 'Go for a walk, call a friend, or move to a different room. Physical movement helps break the thought pattern.',
                    icon: Icons.home,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'I Feel Centered Now',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emergency card widget
class _EmergencyCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _EmergencyCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 1,
              fontFamily: "CrimsonText",
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
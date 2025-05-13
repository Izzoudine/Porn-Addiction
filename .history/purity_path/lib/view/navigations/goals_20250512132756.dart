import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int cleanDays = 0;
  DateTime? _lastRelapseDate;
  bool _hasStartedJourney = false;
  
  // Define goals/milestones
  final List<Map<String, dynamic>> goals = [
    {'days': 4, 'title': '4 Days', 'description': 'Dopamine levels begin to normalize', 'completed': false},
    {'days': 7, 'title': '7 Days', 'description': 'Brain fog starts to clear', 'completed': false},
    {'days': 14, 'title': '14 Days', 'description': 'Energy levels increase significantly', 'completed': false},
    {'days': 21, 'title': '21 Days', 'description': 'New habits begin to form', 'completed': false},
    {'days': 30, 'title': '30 Days', 'description': 'Major milestone in rewiring your brain', 'completed': false},
    {'days': 60, 'title': '60 Days', 'description': 'Significant neural pathway changes', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRelapse = prefs.getString('lastRelapse') ?? DateTime.now().toIso8601String();
    final lastRelapseDate = DateTime.parse(lastRelapse);
    _hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;
    
    // Calculate clean days
    if (_hasStartedJourney) {
      final now = DateTime.now();
      final difference = now.difference(lastRelapseDate);
      cleanDays = difference.inDays;
      
      // Update goal completion status
      for (var i = 0; i < goals.length; i++) {
        goals[i]['completed'] = cleanDays >= goals[i]['days'];
      }
    }
    
    setState(() {
      _lastRelapseDate = lastRelapseDate;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  DateTime _calculateTargetDate(int days) {
    if (_lastRelapseDate == null) return DateTime.now().add(Duration(days: days));
    return _lastRelapseDate!.add(Duration(days: days));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2196F3),
        ),
      ),
      body: _hasStartedJourney 
        ? _buildGoalsContent() 
        : _buildNotStartedContent(),
    );
  }

  Widget _buildNotStartedContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag,
                size: 60,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Journey Not Started',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start your journey on the home page to track your goals and progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Go to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFF2196F3),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$cleanDays',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'days',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_lastRelapseDate != null)
                  Text(
                    'Started on ${_formatDate(_lastRelapseDate!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                const SizedBox(height: 16),
                // Progress bar showing overall progress to 60 days
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress to 60 days',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '${(cleanDays / 60 * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: cleanDays / 60,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.flag,
                  size: 20,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${goals.where((goal) => goal['completed'] as bool).length}/${goals.length} Completed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final goal = goals[index];
              final isCompleted = goal['completed'] as bool;
              final targetDate = _calculateTargetDate(goal['days'] as int);
              // Fixed line - added parentheses for proper order of operations
              final daysLeft = (goal['days'] as int) - cleanDays;
              
              return Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: index == 0 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Goal status indicator
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isCompleted 
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : const Color(0xFF2196F3).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 30,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${goal['days']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      const Text(
                                        'days',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Goal details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      goal['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isCompleted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'COMPLETED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal['description'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isCompleted
                                    ? 'Completed on ${_formatDate(_lastRelapseDate!.add(Duration(days: goal['days'] as int)))}'
                                    : 'Target: ${_formatDate(targetDate)} (${daysLeft > 0 ? "$daysLeft days left" : "Today!"})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress bar
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : cleanDays / (goal['days'] as int),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: goals.length,
          ),
        ),
        
        // Add some bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}
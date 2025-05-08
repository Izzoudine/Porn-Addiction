import 'package:flutter/material.dart';
import '../questionnaire_layout.dart';

class GoalQuestion extends StatefulWidget {
  final String? selectedValue;
  final String otherValue;
  final Function(String) onValueChanged;
  final Function(String) onOtherChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;

  const GoalQuestion({
    Key? key,
    required this.selectedValue,
    required this.otherValue,
    required this.onValueChanged,
    required this.onOtherChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
  }) : super(key: key);

  @override
  State<GoalQuestion> createState() => _GoalQuestionState();
}

class _GoalQuestionState extends State<GoalQuestion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // If no goal is selected yet, default to the first milestone
    if (widget.selectedValue == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onValueChanged('4 days');
      });
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      questionTitle: 'Your Journey to Breaking This Habit',
      onNext: widget.onNext,
      onPrevious: widget.onPrevious,
      canProceed: true, // Always allow proceeding since we set a default
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Science explanation card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'The Science of Habit Breaking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Breaking a habit typically takes anywhere from 18 to 66 days, depending on the person, the habit, and the consistency of effort.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimelineItem(
                          '~3 weeks',
                          'Simple habits',
                          '(18-21 days)',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimelineItem(
                          '2-3 months',
                          'Complex habits',
                          '(up to 66+ days)',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Milestone Journey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'ll guide you through these progressive milestones:',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 20),
            // Timeline of milestones
            _buildMilestoneTimeline(),
            const SizedBox(height: 24),
            // Note about the journey
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFBDBDBD)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Remember, this is a journey. Each milestone builds on the previous one, helping you gradually break free from this habit.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
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
  
  Widget _buildTimelineItem(String title, String subtitle, String days) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            days,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMilestoneTimeline() {
    final milestones = [
      {'days': '4 days', 'description': 'First milestone'},
      {'days': '7 days', 'description': 'One week milestone'},
      {'days': '14 days', 'description': 'Two weeks milestone'},
      {'days': '21 days', 'description': 'Habit pattern changing'},
      {'days': '30 days', 'description': 'One month milestone'},
      {'days': '60 days', 'description': 'Deep habit transformation'},
    ];
    
    return Container(
      height: 280,
      child: ListView.builder(
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final isSelected = widget.selectedValue == milestone['days'];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line and dot
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(
                    right: 16,
                    bottom: index < milestones.length - 1 ? 0 : 16,
                  ),
                  child: Stack(
                    children: [
                      if (index < milestones.length - 1)
                        Positioned(
                          top: 20,
                          bottom: -16,
                          left: 19,
                          width: 2,
                          child: Container(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                          ),
                        ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2E7D32),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Milestone content
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onValueChanged(milestone['days']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone['days']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            milestone['description']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.8) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
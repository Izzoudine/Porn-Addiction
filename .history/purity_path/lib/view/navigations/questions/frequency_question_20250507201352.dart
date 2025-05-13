import 'package:flutter/material.dart';
import '../questionnaire_layout.dart';

class FrequencyQuestion extends StatefulWidget {
  final String? selectedValue;
  final Function(String) onValueChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;

  const FrequencyQuestion({
    Key? key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
  }) : super(key: key);

  @override
  State<FrequencyQuestion> createState() => _FrequencyQuestionState();
}

class _FrequencyQuestionState extends State<FrequencyQuestion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedFrequency = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize selected frequency based on the passed value
    if (widget.selectedValue != null) {
      if (widget.selectedValue == 'Challenging') {
        _selectedFrequency = 2; // Middle of 1-3 range
      } else if (widget.selectedValue == 'Very Challenging') {
        _selectedFrequency = 5; // Middle of 4-6 range
      } else if (widget.selectedValue == 'Extremely Challenging') {
        _selectedFrequency = 8; // Representing 7+ range
      }
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  String _getValueFromFrequency(int frequency) {
    if (frequency >= 1 && frequency <= 3) {
      return 'Challenging';
    } else if (frequency >= 4 && frequency <= 6) {
      return 'Very Challenging';
    } else {
      return 'Extremely Challenging';
    }
  }
  
  String _getDisplayText(int frequency) {
    if (frequency >= 7) {
      return '7+ times per week';
    } else {
      return '$frequency times per week';
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      questionTitle: 'How often do you find yourself struggling with this habit?',
      onNext: widget.onNext,
      onPrevious: widget.onPrevious,
      canProceed: _selectedFrequency > 0,
      showPrevious: false,
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Frequency display
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getFrequencyColor(_selectedFrequency),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getFrequencyColor(_selectedFrequency).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedFrequency > 0 ? _getDisplayText(_selectedFrequency) : 'Select frequency',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFrequency > 0 ? _getChallengeText(_selectedFrequency) : '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Custom frequency selector
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  // Background track
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return Container(
                            width: 4,
                            height: 20,
                            color: Colors.grey[400],
                          );
                        }),
                      ),
                    ),
                  ),
                  // Frequency markers
                  Positioned(
                    left: 15,
                    bottom: 5,
                    child: Text(
                      '1',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    bottom: 5,
                    child: Text(
                      '7+',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // Slider thumb
                  if (_selectedFrequency > 0)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      left: _getPositionForFrequency(_selectedFrequency, context),
                      top: 15,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final width = box.size.width - 80; // Accounting for padding
                          final position = details.localPosition.dx.clamp(0, width);
                          final frequency = ((position / width) * 7).round();
                          setState(() {
                            _selectedFrequency = frequency < 1 ? 1 : frequency > 7 ? 7 : frequency;
                          });
                          widget.onValueChanged(_getValueFromFrequency(_selectedFrequency));
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getFrequencyColor(_selectedFrequency),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getFrequencyColor(_selectedFrequency).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _selectedFrequency >= 7 ? '7+' : _selectedFrequency.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Tap areas for selection
                  Row(
                    children: List.generate(7, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFrequency = index + 1;
                            });
                            widget.onValueChanged(_getValueFromFrequency(_selectedFrequency));
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 80,
                            color: Colors.transparent,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
         ],
        ),
      ),
    );
  }
  
  double _getPositionForFrequency(int frequency, BuildContext context) {
    final width = MediaQuery.of(context).size.width - 88; // Accounting for padding and thumb width
    final position = ((frequency - 1) / 6) * width;
    return position + 15; // Adding left padding
  }
  
  Color _getFrequencyColor(int frequency) {
    if (frequency >= 1 && frequency <= 3) {
      return const Color(0xFF66BB6A); // Green for Challenging
    } else if (frequency >= 4 && frequency <= 6) {
      return const Color(0xFFFFA726); // Orange for Very Challenging
    } else {
      return const Color(0xFFEF5350); // Red for Extremely Challenging
    }
  }
  
  String _getChallengeText(int frequency) {
    if (frequency >= 1 && frequency <= 3) {
      return 'Challenging';
    } else if (frequency >= 4 && frequency <= 6) {
      return 'Very Challenging';
    } else {
      return 'Extremely Challenging';
    }
  }
}
import 'package:flutter/material.dart';
import 'dart:math' as math;
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
        _selectedFrequency = 8; // Middle of 7+ range
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
            // Gauge display
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Frequency Gauge
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background semicircle
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _GaugePainter(
                            gaugeValue: 0,
                            backgroundColor: Colors.grey[200]!,
                            valueColor: Colors.transparent,
                            isBackground: true,
                          ),
                        ),
                        // Value semicircle
                        _selectedFrequency > 0 ? CustomPaint(
                          size: const Size(140, 140),
                          painter: _GaugePainter(
                            gaugeValue: _selectedFrequency / 7,
                            backgroundColor: Colors.transparent,
                            valueColor: _getFrequencyColor(_selectedFrequency),
                            isBackground: false,
                          ),
                        ) : Container(),
                        // Center value display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedFrequency > 0 ? _selectedFrequency.toString() : '0',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _selectedFrequency > 0 
                                    ? _getFrequencyColor(_selectedFrequency) 
                                    : Colors.grey[400],
                              ),
                            ),
                            Text(
                              'times/week',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Value indicator on arc
                        if (_selectedFrequency > 0)
                          Positioned(
                            top: 15,
                            child: Transform.rotate(
                              angle: (math.pi * (_selectedFrequency / 7)) - math.pi / 2,
                              child: Transform.translate(
                                offset: const Offset(0, -50),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _getFrequencyColor(_selectedFrequency),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Challenge level text
                  Text(
                    _selectedFrequency > 0 ? _getChallengeText(_selectedFrequency) : 'Select frequency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedFrequency > 0 
                          ? _getFrequencyColor(_selectedFrequency) 
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Sliding gauge selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Stack(
                  children: [
                    // Value markers and track
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final value = index + 1;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  value == 7 ? '7+' : value.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    // Colored track showing selected range
                    if (_selectedFrequency > 0)
                      Positioned(
                        left: 30,
                        right: 30,
                        top: 39,
                        child: Container(
                          height: 4,
                          child: Row(
                            children: [
                              Flexible(
                                flex: _selectedFrequency,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getFrequencyColor(_selectedFrequency),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      bottomLeft: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 7 - _selectedFrequency,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(2),
                                      bottomRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Slider thumb
                    if (_selectedFrequency > 0)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        left: _calculateSliderPosition(_selectedFrequency, context),
                        top: 15,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final RenderBox box = context.findRenderObject() as RenderBox;
                            final Offset localPosition = box.globalToLocal(details.globalPosition);
                            
                            // Calculate available width for slider (accounting for padding and thumb size)
                            final double availableWidth = box.size.width - 60;
                            final double leftPadding = 30;
                            
                            // Calculate position within available width
                            final double position = (localPosition.dx - leftPadding).clamp(0.0, availableWidth);
                            
                            // Calculate frequency (1-7) based on position
                            final int frequency = (position / availableWidth * 7).ceil();
                            final int clampedFrequency = frequency.clamp(1, 7);
                            
                            if (_selectedFrequency != clampedFrequency) {
                              setState(() {
                                _selectedFrequency = clampedFrequency;
                              });
                              widget.onValueChanged(_getValueFromFrequency(clampedFrequency));
                            }
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
                    // Sliding area - captures initial tap
                    Positioned.fill(
                      child: GestureDetector(
                        onTapDown: (details) {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final Offset localPosition = box.globalToLocal(details.globalPosition);
                          
                          // Calculate available width for slider (accounting for padding)
                          final double availableWidth = box.size.width - 60;
                          final double leftPadding = 30;
                          
                          // Calculate position within available width
                          final double position = (localPosition.dx - leftPadding).clamp(0.0, availableWidth);
                          
                          // Calculate frequency (1-7) based on position
                          final int frequency = (position / availableWidth * 7).ceil();
                          final int clampedFrequency = frequency.clamp(1, 7);
                          
                          setState(() {
                            _selectedFrequency = clampedFrequency;
                          });
                          widget.onValueChanged(_getValueFromFrequency(clampedFrequency));
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
         ],
        ),
      ),
    );
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

// Custom painter for the gauge
class _GaugePainter extends CustomPainter {
  final double gaugeValue; // Value from 0.0 to 1.0
  final Color backgroundColor;
  final Color valueColor;
  final bool isBackground;

  _GaugePainter({
    required this.gaugeValue,
    required this.backgroundColor,
    required this.valueColor,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = isBackground ? backgroundColor : valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    
    // Draw semicircle (180 degrees)
    if (isBackground) {
      // Draw full semicircle background
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        math.pi, // Start from the bottom (180 degrees)
        math.pi, // Sweep 180 degrees (to the top)
        false,
        paint,
      );
    } else {
      // Draw value arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        math.pi, // Start from the bottom (180 degrees)
        math.pi * gaugeValue, // Sweep based on value (0-180 degrees)
        false,
        paint,
      );
    }
    
    // Add tick marks for background
    if (isBackground) {
      final tickPaint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (int i = 0; i <= 7; i++) {
        final angle = math.pi + (math.pi * i / 7);
        final outerPoint = Offset(
          center.dx + (radius - 15) * math.cos(angle),
          center.dy + (radius - 15) * math.sin(angle),
        );
        final innerPoint = Offset(
          center.dx + (radius - 25) * math.cos(angle),
          center.dy + (radius - 25) * math.sin(angle),
        );
        
        canvas.drawLine(innerPoint, outerPoint, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.gaugeValue != gaugeValue ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.valueColor != valueColor;
  }
}
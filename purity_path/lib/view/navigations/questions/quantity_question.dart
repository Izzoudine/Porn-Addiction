import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../questionnaire_layout.dart';

class QuantityQuestion extends StatefulWidget {
  final int? selectedValue;
  final Function(int) onValueChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;

  const QuantityQuestion({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
  });

  @override
  State<QuantityQuestion> createState() => _QuantityQuestionState();
}

class _QuantityQuestionState extends State<QuantityQuestion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedQuantity = 0;
  
  // Available quantity options (in minutes)
  final List<int> _quantityOptions = [10, 20, 30, 40, 50, 60];
  
  @override
  void initState() {
    super.initState();
    
    if (widget.selectedValue != null) {
      // Find the closest valid quantity option
      int closestIndex = 0;
      int minDiff = (widget.selectedValue! - _quantityOptions[0]).abs();
      
      for (int i = 1; i < _quantityOptions.length; i++) {
        int diff = (widget.selectedValue! - _quantityOptions[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
      _selectedQuantity = _quantityOptions[closestIndex];
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

  // Calculate the position for the slider thumb based on quantity
  double _calculateSliderPosition(int quantity, BuildContext context) {
    // Calculate available width accounting for padding and thumb width
    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double leftPadding = 30.0;
    
    // Find index of selected quantity
    final int index = _quantityOptions.indexOf(quantity);
    if (index == -1) return leftPadding - 25;
    
    // Calculate position based on index (6 segments)
    final double segmentWidth = availableWidth / (_quantityOptions.length - 1);
    final double position = index * segmentWidth;
    
    // Center the thumb (thumb width is 50) and add left padding
    return position + leftPadding - 25;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      questionTitle: 'How much time do you typically spend on this habit?',
      onNext: widget.onNext,
      onPrevious: widget.onPrevious,
      canProceed: _selectedQuantity > 0,
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
                  // Quantity Gauge
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
                        _selectedQuantity > 0 ? CustomPaint(
                          size: const Size(140, 140),
                          painter: _GaugePainter(
                            gaugeValue: _getGaugeValue(_selectedQuantity),
                            backgroundColor: Colors.transparent,
                            valueColor: _getQuantityColor(_selectedQuantity),
                            isBackground: false,
                          ),
                        ) : Container(),
                        // Center value display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedQuantity > 0 ? '${_selectedQuantity}' : '0',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _selectedQuantity > 0 
                                    ? _getQuantityColor(_selectedQuantity) 
                                    : Colors.grey[400],
                              ),
                            ),
                            Text(
                              'minutes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Value indicator on arc
                        if (_selectedQuantity > 0)
                          Positioned(
                            top: 15,
                            child: Transform.rotate(
                              angle: (math.pi * _getGaugeValue(_selectedQuantity)) - math.pi / 2,
                              child: Transform.translate(
                                offset: const Offset(0, -50),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _getQuantityColor(_selectedQuantity),
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
                  // Duration level text
                  Text(
                    _selectedQuantity > 0 ? _getDurationText(_selectedQuantity) : 'Select duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedQuantity > 0 
                          ? _getQuantityColor(_selectedQuantity) 
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
                          children: _quantityOptions.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final int value = entry.value;
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
                                  index == _quantityOptions.length - 1 ? '${value}+' : value.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // Colored track showing selected range
                    if (_selectedQuantity > 0)
                      Positioned(
                        left: 30,
                        right: 30,
                        top: 39,
                        child: SizedBox(
                          height: 4,
                          child: Row(
                            children: [
                              Flexible(
                                flex: _quantityOptions.indexOf(_selectedQuantity) + 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getQuantityColor(_selectedQuantity),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      bottomLeft: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: _quantityOptions.length - (_quantityOptions.indexOf(_selectedQuantity) + 1),
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
                    if (_selectedQuantity > 0)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        left: _calculateSliderPosition(_selectedQuantity, context),
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
                            
                            // Calculate index based on position
                            final int index = (position / availableWidth * (_quantityOptions.length - 1)).round();
                            final int clampedIndex = index.clamp(0, _quantityOptions.length - 1);
                            final int selectedQuantity = _quantityOptions[clampedIndex];
                            
                            if (_selectedQuantity != selectedQuantity) {
                              setState(() {
                                _selectedQuantity = selectedQuantity;
                              });
                              widget.onValueChanged(selectedQuantity);
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getQuantityColor(_selectedQuantity),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getQuantityColor(_selectedQuantity).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _selectedQuantity >= 60 ? '60+' : _selectedQuantity.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                          
                          // Calculate index based on position
                          final int index = (position / availableWidth * (_quantityOptions.length - 1)).round();
                          final int clampedIndex = index.clamp(0, _quantityOptions.length - 1);
                          final int selectedQuantity = _quantityOptions[clampedIndex];
                          
                          setState(() {
                            _selectedQuantity = selectedQuantity;
                          });
                          widget.onValueChanged(selectedQuantity);
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
  
  // Get gauge value (0.0 to 1.0) based on selected quantity
  double _getGaugeValue(int quantity) {
    final int index = _quantityOptions.indexOf(quantity);
    if (index == -1) return 0.0;
    return index / (_quantityOptions.length - 1);
  }
  
  Color _getQuantityColor(int quantity) {
    if (quantity >= 10 && quantity <= 20) {
      return const Color(0xFF66BB6A); // Green for Short Duration
    } else if (quantity >= 30 && quantity <= 40) {
      return const Color(0xFFFFA726); // Orange for Moderate Duration
    } else {
      return const Color(0xFFEF5350); // Red for Long Duration
    }
  }
  
  String _getDurationText(int quantity) {
    if (quantity >= 10 && quantity <= 20) {
      return 'Short Duration';
    } else if (quantity >= 30 && quantity <= 40) {
      return 'Moderate Duration';
    } else {
      return 'Long Duration';
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
      
      for (int i = 0; i < 6; i++) {
        final angle = math.pi + (math.pi * i / 5);
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
import 'package:flutter/material.dart';
import '../questionnaire_layout.dart';


class MotivationQuestion extends StatelessWidget {
  final String? selectedValue;
  final Function(String) onValueChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;
  final String nextButtonText;


  const MotivationQuestion({
    Key? key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
    this.nextButtonText = 'Next',

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      questionTitle: 'How strong is your motivation to overcome this challenge?',
      onNext: onNext,
      onPrevious: onPrevious,
      canProceed: canProceed,
      nextButtonText: 'Complete',
      child: Column(
        children: [
          _buildOption(context, 'Very motivated', 'Very motivated'),
          _buildOption(context, 'Somewhat motivated', 'Somewhat motivated'),
          _buildOption(context, 'Unsure', 'Unsure'),
          _buildOption(context, 'Not very motivated', 'Not very motivated'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String value) {
    final isSelected = selectedValue == value;
    
    return GestureDetector(
      onTap: () => onValueChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

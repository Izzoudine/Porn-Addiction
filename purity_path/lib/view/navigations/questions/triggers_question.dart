import 'package:flutter/material.dart';
import '../questionnaire_layout.dart';
class TriggersQuestion extends StatelessWidget {
  final String? selectedValue;
  final String otherValue;
  final Function(String) onValueChanged;
  final Function(String) onOtherChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;

  const TriggersQuestion({
    super.key,
    required this.selectedValue,
    required this.otherValue,
    required this.onValueChanged, 
    required this.onOtherChanged,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      questionTitle: 'What situations or emotions most often lead you to this habit?',
      onNext: onNext,
      onPrevious: onPrevious,
      canProceed: canProceed,
      child: Column(
        children: [
          _buildOption(context, 'Stress', 'Stress'),
          _buildOption(context, 'Boredom', 'Boredom'),
          _buildOption(context, 'Loneliness', 'Loneliness'),
          _buildOption(context, 'Anxiety', 'Anxiety'),
          _buildOption(context, 'Other', 'Other'),
          if (selectedValue == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: TextField(
                value: otherValue,
                onChanged: onOtherChanged,
                decoration: const InputDecoration(
                  hintText: 'Please specify',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
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
            color: isSelected ? const Color(0xFF7EB7FF) : Colors.grey[300]!,
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
                  color: isSelected ? const Color(0xFF7EB7FF) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF7EB7FF) : Colors.white,
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
                  color: isSelected ? const Color(0xFF7EB7FF) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextField extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final InputDecoration decoration;

  const TextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: decoration,
    );
  }
}
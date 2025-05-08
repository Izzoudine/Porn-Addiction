import 'package:flutter/material.dart';

class QuestionLayout extends StatelessWidget {
  final String questionTitle;
  final Widget child;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;
  final bool showPrevious;
  final String nextButtonText;

  const QuestionLayout({
    Key? key,
    required this.questionTitle,
    required this.child,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
    this.showPrevious = true,
    this.nextButtonText = 'Next',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: child)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 48,
                child: showPrevious 
                  ? ElevatedButton(
                      onPressed: onPrevious,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(), // Empty SizedBox when no Previous button
              ),
              
              const SizedBox(width: 16),
              
              SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: canProceed ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    nextButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
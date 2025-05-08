import 'package:flutter/material.dart';

class QuestionnaireCompletion extends StatelessWidget {
  final Map<String, dynamic> responses;

  const QuestionnaireCompletion({
    Key? key,
    required this.responses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 32),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your responses have been recorded. We will personalize your journey based on your answers.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the main app
                  // This would typically go to your app's main dashboard
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Placeholder(), // Replace with your main app screen
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Begin Your Journey',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
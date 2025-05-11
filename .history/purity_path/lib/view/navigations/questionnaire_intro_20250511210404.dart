import 'package:flutter/material.dart';
import 'questionnaire_manager.dart';

class QuestionnaireIntroPage extends StatelessWidget {
  const QuestionnaireIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3EFFF), Color(0xFFDCEBFF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Blue wave at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 200),
                  painter: WavePainter(),
                ),
              ),
              /*  
              // Progress indicator at top
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.15,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
              ),
              */
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                        child: Column(
                          children: [
                            // Main title text
                            const Text(
                              "A few quick questions",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "to personalize your experience.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Subtitle/description
                            const Text(
                              "Please take a moment to complete. It will help us understand your needs better and ensure that your experience is personalized to suit you.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                                height: 1.5,
                              ),
                            ),

                            // Floating images
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(height: 220, width: double.infinity),

                                // Laptop image
                                Positioned(
                                  child: Image.asset(
                                    'assets/images/mosque.png',
                                    width: 500,
                                    height: 290,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom button and link
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuestionnaireManager(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 56),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the wave shape
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF3FA9FF)
          ..style = PaintingStyle.fill;

    final path = Path();

    // Start from the bottom-left
    path.moveTo(0, size.height);

    // Draw wave
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );

    // Line to bottom-right corner
    path.lineTo(size.width, size.height);

    // Line back to starting point
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

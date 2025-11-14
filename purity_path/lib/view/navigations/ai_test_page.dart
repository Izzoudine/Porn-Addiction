import 'package:flutter/material.dart';
import 'package:purity_path/data/services/gemini_ai_service.dart';

/// Simple test widget to verify AI integration is working
/// You can add this to your app temporarily to test the AI
class AITestPage extends StatefulWidget {
  const AITestPage({super.key});

  @override
  State<AITestPage> createState() => _AITestPageState();
}

class _AITestPageState extends State<AITestPage> {
  String _response = '';
  bool _isLoading = false;

  Future<void> _testAI() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await GeminiAIService.getRecoverySupport(
        userMessage: 'Hello, can you help me with my recovery journey?',
        context: 'Testing AI integration',
      );

      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testEmergencySupport() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await GeminiAIService.getEmergencySupport();

      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Test'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test AI Integration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test Basic AI Response'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmergencySupport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test Emergency Support'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Waiting for AI response...'),
                  ],
                ),
              ),
            if (_response.isNotEmpty && !_isLoading)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _response,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

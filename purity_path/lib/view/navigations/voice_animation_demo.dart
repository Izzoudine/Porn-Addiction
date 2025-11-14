import 'package:flutter/material.dart';
import 'package:purity_path/data/services/tts_service.dart';
import 'package:purity_path/data/services/ai_voice_intervention_service.dart';
import 'package:purity_path/widgets/tts_context_provider.dart';

/// Demo page to test voice animation overlay
class VoiceAnimationDemo extends StatefulWidget {
  const VoiceAnimationDemo({super.key});

  @override
  State<VoiceAnimationDemo> createState() => _VoiceAnimationDemoState();
}

class _VoiceAnimationDemoState extends State<VoiceAnimationDemo> {
  @override
  Widget build(BuildContext context) {
    return TTSContextProvider(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Voice Animation Demo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.waves, color: Colors.white, size: 50),
                    SizedBox(height: 12),
                    Text(
                      'Voice Animation System',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'See the visual voice animation when AI speaks',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Test Different Interventions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 16),

              // Test buttons
              _buildTestButton(
                icon: Icons.warning_amber,
                title: 'Immediate Stop',
                description: 'Quick intervention message',
                color: Colors.orange,
                onTap: () async {
                  await TTSService.speak(
                    "Stop! Brother, this is not who you are. Remember Allah is watching. You are stronger than this urge.",
                  );
                },
              ),

              _buildTestButton(
                icon: Icons.mosque,
                title: 'Islamic Reminder',
                description: 'Quranic verse and guidance',
                color: Colors.green,
                onTap: () async {
                  await TTSService.islamicReminder();
                },
              ),

              _buildTestButton(
                icon: Icons.psychology,
                title: 'AI Personalized',
                description: 'AI-generated intervention',
                color: Colors.purple,
                onTap: () async {
                  await AIVoiceInterventionService.onPornDetected(
                    cleanStreak: 5,
                    userName: 'Ahmad',
                  );
                },
              ),

              _buildTestButton(
                icon: Icons.sos,
                title: 'Emergency Support',
                description: 'Breathing + urgent help',
                color: Colors.red,
                onTap: () async {
                  await AIVoiceInterventionService.triggerEmergencySupport();
                },
              ),

              _buildTestButton(
                icon: Icons.self_improvement,
                title: 'Breathing Exercise',
                description: 'Guided breathing with animation',
                color: Colors.blue,
                onTap: () async {
                  await TTSService.breathingExercise();
                },
              ),

              _buildTestButton(
                icon: Icons.access_time,
                title: 'Continuous Reminder',
                description: 'Ongoing session warning',
                color: Colors.deepOrange,
                onTap: () async {
                  await TTSService.speak(
                    "You've been here for 2 minutes. This needs to stop NOW. Stand up, make wudu, and pray 2 rakah.",
                  );
                },
              ),

              const SizedBox(height: 30),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'The visual overlay appears fullscreen with animated voice waves. You can close it anytime by tapping the X button.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

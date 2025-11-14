import 'package:flutter/material.dart';
import 'package:purity_path/data/services/ai_voice_intervention_service.dart';
import 'package:purity_path/data/services/tts_service.dart';

class VoiceInterventionSettingsPage extends StatefulWidget {
  const VoiceInterventionSettingsPage({super.key});

  @override
  State<VoiceInterventionSettingsPage> createState() =>
      _VoiceInterventionSettingsPageState();
}

class _VoiceInterventionSettingsPageState
    extends State<VoiceInterventionSettingsPage> {
  bool _isEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await AIVoiceInterventionService.isVoiceInterventionEnabled();
    setState(() {
      _isEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleVoiceIntervention(bool value) async {
    setState(() => _isEnabled = value);
    await AIVoiceInterventionService.setVoiceInterventionEnabled(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Voice intervention enabled'
                : 'Voice intervention disabled',
          ),
          backgroundColor: value ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _testVoice() async {
    await TTSService.speak(
      "This is a test of the AI voice intervention. When you start watching inappropriate content, I will speak to you like this to help you stop.",
    );
  }

  Future<void> _testEmergencySupport() async {
    await AIVoiceInterventionService.triggerEmergencySupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Voice Intervention',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: const Row(
                      children: [
                        Icon(Icons.record_voice_over,
                            color: Colors.white, size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Voice Intervention',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real-time audio support when you need it most',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Enable/Disable Switch
                  Card(
                    child: SwitchListTile(
                      title: const Text(
                        'Enable Voice Intervention',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'AI will speak to you when porn is detected',
                      ),
                      value: _isEnabled,
                      onChanged: _toggleVoiceIntervention,
                      activeColor: const Color(0xFF2196F3),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // How it works
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    icon: Icons.warning_amber,
                    title: 'Immediate Intervention',
                    description:
                        'When porn is detected, AI voice immediately speaks to interrupt the pattern',
                    color: Colors.orange,
                  ),

                  _buildFeatureCard(
                    icon: Icons.access_time,
                    title: 'Continuous Reminders',
                    description:
                        'Every 30 seconds, voice reminders to help you stop',
                    color: Colors.blue,
                  ),

                  _buildFeatureCard(
                    icon: Icons.psychology,
                    title: 'AI-Generated Support',
                    description:
                        'Personalized messages based on your streak and progress',
                    color: Colors.purple,
                  ),

                  _buildFeatureCard(
                    icon: Icons.mosque,
                    title: 'Islamic Guidance',
                    description: 'Quranic verses and Islamic reminders',
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  // Test buttons
                  const Text(
                    'Test Voice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testVoice,
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Test Basic Voice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testEmergencySupport,
                      icon: const Icon(Icons.sos),
                      label: const Text('Test Emergency Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                            'Voice intervention works best with headphones or speaker. Make sure your device volume is on.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          ],
        ),
      ),
    );
  }
}

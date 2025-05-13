import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptancePage extends StatelessWidget {
  const AcceptancePage({Key? key}) : super(key: key);

  Future<void> _startJourney(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasStartedJourney', true);
    await prefs.setString('lastRelapse', DateTime.now().toIso8601String());
    
    // Return true to indicate journey has started
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    size: 40,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "POINT OF NO RETURN",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "By proceeding, you agree to the following terms:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildWarningItem(
                        "VPN Blocking",
                        "This app will block all VPN connections on your device to prevent access to restricted content.",
                      ),
                      _buildWarningItem(
                        "Uninstallation Prevention",
                        "Once activated, you will not be able to uninstall this app without completing a 7-day waiting period.",
                      ),
                      _buildWarningItem(
                        "Device Monitoring",
                        "The app will monitor your device usage patterns to identify and block potential triggers.",
                      ),
                      _buildWarningItem(
                        "Browser Restrictions",
                        "All browsers on your device will be forced to use safe search and content filtering.",
                      ),
                      _buildWarningItem(
                        "App Restrictions",
                        "Certain apps that may contain triggering content will be blocked during high-risk hours.",
                      ),
                      _buildWarningItem(
                        "Data Collection",
                        "Your usage patterns will be analyzed locally on your device to improve protection.",
                      ),
                      _buildWarningItem(
                        "Accountability",
                        "The app may require you to check in regularly to maintain your progress.",
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "This is a serious commitment to your spiritual and personal growth. These measures are designed to help you succeed in your journey to purity.",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "I'M NOT READY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startJourney(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "START",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildWarningItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.red.shade700,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
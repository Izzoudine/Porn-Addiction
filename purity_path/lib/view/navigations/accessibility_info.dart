import 'package:flutter/material.dart';
import 'package:purity_path/data/services/permissions_service.dart';
import 'package:purity_path/utils/consts.dart';

class AccessibilityInfoPage extends StatefulWidget {
  const AccessibilityInfoPage({super.key});

  @override
  _AccessibilityInfoPageState createState() => _AccessibilityInfoPageState();
}

class _AccessibilityInfoPageState extends State<AccessibilityInfoPage> {
  bool _isAccessibilityEnabled = false;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _checkAccessibilityStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isEnabled = await PermissionService.isAccessibilityServiceEnabled();
      setState(() {
        _isAccessibilityEnabled = isEnabled;
        _errorMessage = '';
      });
      if (isEnabled) {
        Navigator.pop(context, true); // Return to PermissionsScreen
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking accessibility: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestAccessibilityPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await PermissionService.requestAccessibilityPermission();
      await Future.delayed(const Duration(seconds: 1));
      await _checkAccessibilityStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting accessibility: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAccessibilityStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Accessibility Permission',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Loading indicator
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              // Header image
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.accessibility_new,
                    size: 60,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Center(
                child: Text(
                  'Why We Need Accessibility Permission',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Text(
                  'Our app needs accessibility permission to monitor and block inappropriate applications and content. This is a critical permission that allows us to protect you from harmful content.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
                ),
              ),
              const SizedBox(height: 24),
              // What we do section
              const Text(
                'What We Do With This Permission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.block,
                title: 'Block Inappropriate Apps',
                description:
                    'We detect and block access to adult applications and content.',
              ),
              _buildInfoItem(
                icon: Icons.timer,
                title: 'Monitor Screen Time',
                description:
                    'We track app usage to enforce time limits and schedules.',
              ),
              _buildInfoItem(
                icon: Icons.shield,
                title: 'Protect Against Harmful Content',
                description:
                    'We prevent access to websites with inappropriate content.',
              ),
              const SizedBox(height: 24),
              // Privacy commitment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Our Privacy Commitment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• We do NOT collect or store your personal data\n'
                      '• We do NOT track your location\n'
                      '• We do NOT share any information with third parties\n'
                      '• All content filtering happens directly on your device',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Enable button
              ElevatedButton(
                onPressed:
                    _isLoading || _isAccessibilityEnabled
                        ? null
                        : _requestAccessibilityPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isAccessibilityEnabled
                      ? 'Accessibility Service Enabled'
                      : 'Enable Accessibility Service',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Skip button
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.pop(context, false),
                child: const Center(
                  child: Text(
                    'Skip for now (Limited Protection)',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

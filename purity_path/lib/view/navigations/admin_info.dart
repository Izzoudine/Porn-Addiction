import 'package:flutter/material.dart';
import 'package:purity_path/data/services/permissions_service.dart';

class AdminInfoPage extends StatefulWidget {
  const AdminInfoPage({super.key});

  @override
  _AdminInfoPageState createState() => _AdminInfoPageState();
}

class _AdminInfoPageState extends State<AdminInfoPage> {
  bool _isAdminEnabled = false;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _checkAdminStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isEnabled = await PermissionService.isDeviceAdminPermissionGranted();
      setState(() {
        _isAdminEnabled = isEnabled;
        _errorMessage = '';
      });
      if (isEnabled) {
        Navigator.pop(context, true); // Return to PermissionsScreen
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking admin status: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestAdminPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await PermissionService.requestDeviceAdminPermission("PurityPath needs device admin access to prevent unauthorized uninstallation and ensure continuous protection for your family.");
      await Future.delayed(const Duration(seconds: 1));
      await _checkAdminStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting admin permission: $e';
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
    _checkAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Device Admin Permission',
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
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Center(
                child: Text(
                  'Why We Need Device Admin Permission',
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
                  'Our app needs device administrator permission to provide comprehensive protection and prevent unauthorized access or uninstallation of the app.',
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
                icon: Icons.lock,
                title: 'Prevent App Uninstallation',
                description:
                    'Protect against unauthorized removal of the parental control app.',
              ),
              _buildInfoItem(
                icon: Icons.security,
                title: 'Secure System Settings',
                description:
                    'Prevent changes to critical device settings that could bypass protections.',
              ),
              _buildInfoItem(
                icon: Icons.power_settings_new,
                title: 'Lock Screen Control',
                description:
                    'Manage device lock screen and password policies for enhanced security.',
              ),
              _buildInfoItem(
                icon: Icons.app_blocking,
                title: 'App Installation Control',
                description:
                    'Block installation of unauthorized apps from unknown sources.',
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
                        Icon(Icons.verified_user, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Our Security Promise',
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
                      '• Admin permissions are used ONLY for protection purposes\n'
                      '• We do NOT access your personal files or data\n'
                      '• We do NOT modify system settings beyond safety controls\n'
                      '• All administrative actions are transparent and reversible',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Warning section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD97706)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Important Note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Without admin permission, advanced protections may be easily bypassed. This permission ensures maximum security.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Enable button
              ElevatedButton(
                onPressed:
                    _isLoading || _isAdminEnabled
                        ? null
                        : _requestAdminPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isAdminEnabled
                      ? 'Device Admin Enabled'
                      : 'Enable Device Administrator',
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
                    'Skip for now (Reduced Security)',
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
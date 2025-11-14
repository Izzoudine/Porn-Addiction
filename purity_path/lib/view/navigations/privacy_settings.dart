import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _isLoading = true;
  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _personalizedContent = true;
  bool _notificationsEnabled = true;
  bool _dataBackupEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _crashReportsEnabled = prefs.getBool('crash_reports_enabled') ?? true;
      _personalizedContent = prefs.getBool('personalized_content') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _dataBackupEnabled = prefs.getBool('data_backup_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Privacy Settings',
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 50,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your Privacy Matters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Control how your data is used and shared',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Data Collection Section
                    _buildSection(
                      'Data Collection',
                      Icons.analytics_outlined,
                      [
                        _buildSwitchItem(
                          icon: Icons.insert_chart_outlined,
                          title: 'Analytics',
                          subtitle: 'Help us improve the app with usage data',
                          value: _analyticsEnabled,
                          onChanged: (value) {
                            setState(() => _analyticsEnabled = value);
                            _updateSetting('analytics_enabled', value);
                          },
                        ),
                        const Divider(height: 1),
                        _buildSwitchItem(
                          icon: Icons.bug_report_outlined,
                          title: 'Crash Reports',
                          subtitle: 'Automatically send error reports',
                          value: _crashReportsEnabled,
                          onChanged: (value) {
                            setState(() => _crashReportsEnabled = value);
                            _updateSetting('crash_reports_enabled', value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Personalization Section
                    _buildSection(
                      'Personalization',
                      Icons.person_outline,
                      [
                        _buildSwitchItem(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Personalized Content',
                          subtitle: 'Customize content based on your journey',
                          value: _personalizedContent,
                          onChanged: (value) {
                            setState(() => _personalizedContent = value);
                            _updateSetting('personalized_content', value);
                          },
                        ),
                        const Divider(height: 1),
                        _buildSwitchItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Receive reminders and encouragement',
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                            _updateSetting('notifications_enabled', value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Data Management Section
                    _buildSection(
                      'Data Management',
                      Icons.cloud_outlined,
                      [
                        _buildSwitchItem(
                          icon: Icons.backup_outlined,
                          title: 'Cloud Backup',
                          subtitle: 'Save your progress to the cloud',
                          value: _dataBackupEnabled,
                          onChanged: (value) {
                            setState(() => _dataBackupEnabled = value);
                            _updateSetting('data_backup_enabled', value);
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.delete_outline,
                          title: 'Clear App Data',
                          subtitle: 'Remove all local data',
                          color: Colors.red,
                          onTap: () => _showClearDataDialog(),
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.download_outlined,
                          title: 'Export My Data',
                          subtitle: 'Download a copy of your data',
                          color: const Color(0xFF2196F3),
                          onTap: () => _exportData(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Privacy Info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF2196F3),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Data is Protected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We use industry-standard encryption to keep your information secure. Your journey is private and confidential.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2196F3)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
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
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Clear All Data?'),
            ],
          ),
          content: const Text(
            'This will permanently delete all your local data including progress, settings, and history. This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been cleared'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Data'),
            ),
          ],
        );
      },
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon!'),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }
}

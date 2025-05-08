import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings logic would go here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Text(
                  'M',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Muslim_Brother',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Member since ${DateFormat('MMMM yyyy').format(DateTime.now().subtract(const Duration(days: 60)))}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Journey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildJourneyCard(
                  title: 'Current Streak',
                  value: '7 days',
                  icon: Icons.trending_up,
                  color: Colors.teal,
                ),
                _buildJourneyCard(
                  title: 'Best Streak',
                  value: '18 days',
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildJourneyCard(
                  title: 'Duas Read',
                  value: '24',
                  icon: Icons.menu_book,
                  color: Colors.indigo,
                ),
                _buildJourneyCard(
                  title: 'Motivations',
                  value: '31',
                  icon: Icons.psychology,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalItem(
                      title: '7 days clean',
                      progress: 1.0,
                      completed: true,
                    ),
                    const Divider(height: 24),
                    _buildGoalItem(
                      title: '30 days clean',
                      progress: 7 / 30,
                      completed: false,
                    ),
                    const Divider(height: 24),
                    _buildGoalItem(
                      title: '90 days clean',
                      progress: 7 / 90,
                      completed: false,
                    ),
                    const Divider(height: 24),
                    _buildGoalItem(
                      title: 'Read 50 duas',
                      progress: 24 / 50,
                      completed: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Daily reminders, emergency alerts',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.psychology,
              title: 'Triggers',
              subtitle: 'Manage your known triggers',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.security,
              title: 'App Lock',
              subtitle: 'Secure your app with PIN or biometric',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Get Help',
              subtitle: 'Professional resources and support',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Log out logic would go here
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Purity Path v1.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required double progress,
    required bool completed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: completed ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                      color: completed ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: 300 * progress,
                    decoration: BoxDecoration(
                      color: completed ? Colors.green : Colors.teal,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                completed
                    ? 'Completed!'
                    : '${(progress * 100).toInt()}% completed',
                style: TextStyle(
                  fontSize: 12,
                  color: completed ? Colors.green : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.teal,
                ),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Support & Guidance',
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
                      Icons.support_agent,
                      size: 50,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'re Here to Help',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get the support you need on your journey',
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

            // Quick Actions
            _buildSection(
              context,
              'Get Help',
              Icons.help_outline,
              [
                _buildSupportItem(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'support@puritypath.com',
                  color: const Color(0xFF2196F3),
                  onTap: () => _launchEmail('support@puritypath.com'),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Chat with our support team',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.phone_outlined,
                  title: 'Helpline',
                  subtitle: 'Call us for urgent support',
                  color: const Color(0xFFFF9800),
                  onTap: () => _launchPhone('+1234567890'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Resources
            _buildSection(
              context,
              'Resources',
              Icons.library_books_outlined,
              [
                _buildSupportItem(
                  icon: Icons.quiz_outlined,
                  title: 'FAQs',
                  subtitle: 'Find answers to common questions',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _navigateToFAQ(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.video_library_outlined,
                  title: 'Video Tutorials',
                  subtitle: 'Learn how to use the app',
                  color: const Color(0xFFE91E63),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.article_outlined,
                  title: 'User Guide',
                  subtitle: 'Comprehensive app documentation',
                  color: const Color(0xFF00BCD4),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Community
            _buildSection(
              context,
              'Community',
              Icons.people_outline,
              [
                _buildSupportItem(
                  icon: Icons.forum_outlined,
                  title: 'Community Forum',
                  subtitle: 'Connect with others on the same journey',
                  color: const Color(0xFF3F51B5),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.groups_outlined,
                  title: 'Support Groups',
                  subtitle: 'Join a support group near you',
                  color: const Color(0xFF009688),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feedback
            _buildSection(
              context,
              'Feedback',
              Icons.feedback_outlined,
              [
                _buildSupportItem(
                  icon: Icons.rate_review_outlined,
                  title: 'Rate the App',
                  subtitle: 'Share your experience',
                  color: const Color(0xFFFFC107),
                  onTap: () => _showComingSoonSnackbar(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  color: const Color(0xFFF44336),
                  onTap: () => _reportBug(context),
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  icon: Icons.lightbulb_outline,
                  title: 'Suggest a Feature',
                  subtitle: 'Tell us what you\'d like to see',
                  color: const Color(0xFF673AB7),
                  onTap: () => _suggestFeature(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Emergency Support
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade50, Colors.orange.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.crisis_alert,
                      color: Colors.red.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Immediate Help?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'If you\'re in crisis, please reach out to a mental health professional or crisis helpline immediately.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _launchPhone('988'),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call Crisis Helpline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
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

  Widget _buildSupportItem({
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
              child: Icon(icon, color: color, size: 22),
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
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Purity Path Support Request',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _navigateToFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQPage()),
    );
  }

  void _reportBug(BuildContext context) {
    _launchEmail('bugs@puritypath.com');
  }

  void _suggestFeature(BuildContext context) {
    _launchEmail('features@puritypath.com');
  }

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How does the app help me overcome addiction?',
        'answer':
            'Purity Path combines content filtering, daily Islamic guidance, progress tracking, and accountability features to support your journey towards digital purity.',
      },
      {
        'question': 'Is my data secure and private?',
        'answer':
            'Yes, all your data is encrypted and stored securely. We never share your personal information with third parties.',
      },
      {
        'question': 'Can I use the app without an internet connection?',
        'answer':
            'Many features work offline, including your progress tracking and saved lessons. However, some features like content filtering and updates require an internet connection.',
      },
      {
        'question': 'What are the accessibility permissions for?',
        'answer':
            'Accessibility permissions allow the app to monitor and block inappropriate content across your device, helping you stay protected.',
      },
      {
        'question': 'How do I reset my progress?',
        'answer':
            'You can reset your progress from the Goals page. However, this action cannot be undone, so please use it carefully.',
      },
      {
        'question': 'Is there a cost to use the app?',
        'answer':
            'Purity Path is free to use. We may offer premium features in the future, but core functionality will always be free.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              title: Text(
                faqs[index]['question']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              children: [
                Text(
                  faqs[index]['answer']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

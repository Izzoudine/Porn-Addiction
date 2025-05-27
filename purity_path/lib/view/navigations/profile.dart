import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isGuest = false;
  String _userName = "Invité";
  String _userEmail = "";
  final int _cleanDays = 0;
  final int _totalRelapses = 0;
  DateTime? _lastRelapseDate;
  DateTime? _accountCreationDate;
  final bool _hasStartedJourney = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final isGuest = prefs.getBool("isGuest") ?? false;
    _isGuest = isGuest;

    final userName = prefs.getString('name') ?? "Invité";
    final userEmail = prefs.getString('email') ?? "";
    // final totalRelapses = prefs.getInt('totalRelapses') ?? 0;
    // final accountCreationDateStr = prefs.getString('accountCreationDate');
    // final hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;

    // final lastRelapseStr = prefs.getString('lastRelapse');
    // DateTime? lastRelapseDate;
    // int cleanDays = 0;

    // if (lastRelapseStr != null && hasStartedJourney) {
    //   lastRelapseDate = DateTime.parse(lastRelapseStr);
    //   final now = DateTime.now();
    //   cleanDays = now.difference(lastRelapseDate).inDays;
    // }

    // // Récupérer ou définir la date de création du compte
    // DateTime accountCreationDate;
    // if (accountCreationDateStr != null) {
    //   accountCreationDate = DateTime.parse(accountCreationDateStr);
    // } else {
    //   accountCreationDate = DateTime.now();
    //   await prefs.setString(
    //     'accountCreationDate',
    //     accountCreationDate.toIso8601String(),
    //   );
    // }

    setState(() {
      _isGuest = isGuest;
      _userName = userName;
      _userEmail = userEmail;
      // _cleanDays = cleanDays;
      // _totalRelapses = totalRelapses;
      // _lastRelapseDate = lastRelapseDate;
      // _accountCreationDate = accountCreationDate;
      // _hasStartedJourney = hasStartedJourney;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    // Utiliser le format de date sans spécifier de locale
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.setBool("isGuest", false);
      _isGuest = await isGuest;

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      prefs.setString("name", userCredential.user!.displayName!);
      prefs.setString("email", userCredential.user!.email!);

      // Save to Real-Time Database
      final database = FirebaseDatabase.instance.ref();
      await database.child('users/${userCredential.user!.uid}').set({
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'createdAt': ServerValue.timestamp,
        'lastActive': ServerValue.timestamp,
        'startDate': null,
      });

      final String? guestChoiceJson = prefs.getString("guestChoice");

      final Map<String, dynamic> loadedTriggerData = jsonDecode(
        guestChoiceJson!,
      );
      // Now you can access the values:
      final String triggers = loadedTriggerData['triggers'];
      final String frequency = loadedTriggerData['frequency'];
      final String motivation = loadedTriggerData['motivation'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastActive': FieldValue.serverTimestamp(),
            'triggers': triggers,
            'frequency': frequency,
            'motivation': motivation,
            'cleanStreak': 0,
            'totalCleanDays': 0,
            'startDate': null,
            'achievedGoals': [],
            'currentGoalId': '',
            'hasCompletedQuestionnaire': true,
          }, SetOptions(merge: true));

      // Check if the widget is still mounted before showing SnackBar
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${userCredential.user!.email}')),
      );

      // Navigate to the next screen after sign-in
      if (mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.navigation);
      }
    } catch (e) {
      if (e.hashCode == 'network_error') {
        print("This is our${e.hashCode}");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
        }
      }
      print('Google Sign-In error: $e');
      // Check if the widget is still mounted before showing SnackBar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // En-tête du profil
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
                          // Avatar et badge invité
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2196F3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _userName.isNotEmpty
                                        ? _userName[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                ),
                              ),
                              // Badge invité
                              if (_isGuest)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "INVITÉ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Nom d'utilisateur
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          if (_userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Bouton de connexion pour les invités
                          if (_isGuest)
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => signInWithGoogle(context),
                              icon: const Icon(Icons.login),
                              label: const Text("Log In"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),               
                    const SizedBox(height: 24),

                    // Liste des options
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
                      child: Column(
                        children: [
                          _buildOptionItem(
                            icon: Icons.language_outlined,
                            title: "App Language",
                            subtitle: "Choose your preferred language",
                            onTap: () {
                              // Action pour changer la langue
                            },
                          ),
                            const Divider(height: 1),
                          _buildOptionItem(
                            icon: Icons.security_outlined,
                            title: "Privacy Settings",
                            subtitle: "Manage app permissions",
                            onTap: () {
                              // Action pour changer la langue
                            },
                          ),
                          const Divider(height: 1),
                          _buildOptionItem(
                            icon: Icons.help_outline,
                            title: "Support & Guidance",
                            subtitle: "Get help or contact our team",

                            onTap: () {
                              // Action pour l'aide
                            },
                          ),
                          const Divider(height: 1),
                          _buildOptionItem(
                            icon: Icons.info_outline,
                            title: "About Purity Path",
                            subtitle: "Learn about our mission",
                            onTap: () {
                              // Action pour à propos
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton de déconnexion
                    if (!_isGuest)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await signOut();
                            Navigator.pushReplacementNamed(
                              context,
                              RoutesName.welcome,
                            );

                            // Optionally: Navigator.pop(context); or other logic
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Log Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('name');
    await prefs.remove('email'); 
    await prefs.remove('isGuest'); 
  } catch (e) {
    print('Error during sign-out: $e');
    rethrow; 
  }
}

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    String? subtitle,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

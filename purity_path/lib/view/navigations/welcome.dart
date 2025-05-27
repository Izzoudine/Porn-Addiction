import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:purity_path/utils/consts.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
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
      final prefs = await SharedPreferences.getInstance();
      String? name = userCredential.user!.displayName;
      String? email = userCredential.user!.email;
      prefs.setString("name",name!);
      prefs.setString("email",email!);

      // Save to Real-Time Database
      final database = FirebaseDatabase.instance.ref();
      await database.child('users/${userCredential.user!.uid}').set({
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'createdAt': ServerValue.timestamp,
        'lastActive': ServerValue.timestamp,
        'startDate': null,
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastActive': FieldValue.serverTimestamp(),
            'triggers': '',
            'frequency': '',
            'motivation': '',
            'cleanStreak': 0,
            'totalCleanDays': 0,
            'startDate': null,
            'achievedGoals': [],
            'currentGoalId': '',
            'hasCompletedQuestionnaire': false,
          }, SetOptions(merge: true));

      // Check if the widget is still mounted before showing SnackBar
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${userCredential.user!.email}')),
      );

      // Navigate to the next screen after sign-in
      if (mounted) {
        Navigator.pushNamed(context, RoutesName.questionnaireIntro);
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

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isGuest", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(AppColors.secondary), // Rich blue at top
              Color(AppColors.primary), // Lighter blue at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo at the top
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.healing,
                      color: Color(AppColors.secondary),
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Welcome text
                const Text(
                  'Welcome to NoFap Islam',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16), const SizedBox(height: 10),

                // App illustration
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),

                      // App icons with different colors
                      Positioned(
                        top: 40,
                        left: 70,
                        child: _buildAppIcon(Colors.green.shade300, 60), // Blue
                      ),
                      Positioned(
                        bottom: 40,
                        right: 60,
                        child: _buildAppIcon(
                          Colors.orange.shade300,
                          70,
                        ), // Green
                      ),
                      Positioned(
                        bottom: 60,
                        left: 50,
                        child: _buildAppIcon(Colors.red.shade300, 60), // Red
                      ),
                      Positioned(
                        top: 70,
                        right: 50,
                        child: _buildAppIcon(
                          Colors.purple.shade300,
                          55,
                        ), // Violet
                      ),

                      // Tagline in the middle of the illustration
                      const Text(
                        'Regain control over\nyour screen time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Let's do it button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => signInWithGoogle(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                // Already a member
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.questionnaireIntro);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Your data is saved temporarily as a guest. Sign in to keep your information safe and available anywhere!",
                        ),
                      ),
                    );
                    save();
                  },
                  child: const Text(
                    "Continue as a guest",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Terms and Privacy
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By proceeding, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to privacy policy
                                },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Conditions of Use',
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to terms
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

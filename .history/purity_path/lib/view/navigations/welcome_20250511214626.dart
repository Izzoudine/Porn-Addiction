import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'questionnaire_intro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  zero() {}
  /*
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, navigate to the questionnaire intro page
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Navigate to questionnaire intro page
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuestionnaireIntroPage()),
        );
      }
      
      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
      return null;
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2468DC), // Rich blue at top
              Color(0xFF7EB7FF), // Lighter blue at bottom
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
                      color: Color(0xFF2468DC),
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

                const SizedBox(height: 16),

                // Purpose of the app
                /*             const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Your companion on the journey to purity and spiritual growth through Islamic principles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
*/
                const SizedBox(height: 10),

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
                        bottom: 50,
                        right: 60,
                        child: _buildAppIcon(
                          Colors.orange.shade300,
                          70,
                        ), // Green
                      ),
                      Positioned(
                        bottom: 80,
                        left: 50,
                        child: _buildAppIcon(Colors.red.shade300, 65), // Red
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
                    onPressed: _isLoading ? null : zero,
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
                    // Handle existing user login
                    //   _signInWithGoogle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionnaireIntroPage(),
                      ),
                    );
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

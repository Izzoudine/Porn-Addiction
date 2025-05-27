import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purity_path/data/services/notification_service.dart';
import 'package:purity_path/utils/routes/routes.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:purity_path/view/navigations/dailiy_update.dart';
import 'firebase_options.dart';
import 'package:purity_path/view/navigations/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DailiesUpdater.checkForUpdatesOnStart();
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoFap Islam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Merriweather',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      onGenerateRoute: AppPages.onGenerateRoute,
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return UserDataWrapper(userId: snapshot.data!.uid);
        }

        // Not authenticated, navigate to welcome
        return const LoginPage();
      },
    );
  }
}

class UserDataWrapper extends StatelessWidget {
  final String userId;

  const UserDataWrapper({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
      builder: (context, docSnapshot) {
        if (docSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Check if questionnaire is completed
        bool hasCompletedQuestionnaire = false;
        if (docSnapshot.hasData && docSnapshot.data!.exists) {
          final data = docSnapshot.data!.data() as Map<String, dynamic>?;
          hasCompletedQuestionnaire =
              data?['hasCompletedQuestionnaire'] ?? false;
        }

        // Navigate to the appropriate route based on questionnaire status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hasCompletedQuestionnaire) {
            Navigator.of(context).pushReplacementNamed(RoutesName.navigation);
          } else {
            Navigator.of(
              context,
            ).pushReplacementNamed(RoutesName.questionnaireIntro);
          }
        });

        // Return a loading indicator while navigation is being processed
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:purity_path/view/navigation.dart';
import 'package:purity_path/view/lessons/duas.dart';
import 'package:purity_path/view/lessons/haddiths.dart';
import 'package:purity_path/view/lessons/motivations.dart';
import 'package:purity_path/view/navigations/accessibility_info.dart';
import 'package:purity_path/view/navigations/admin_info.dart';
import 'package:purity_path/view/navigations/welcome.dart';
import 'package:purity_path/view/navigations/permissions.dart';
import 'package:purity_path/view/navigations/questionnaire_manager.dart';
import 'package:purity_path/view/navigations/questionnaire_intro.dart';

class AppPages {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Log route navigation - use only debugPrint for consistency
    debugPrint("Navigating to: ${settings.name}");
    
    switch (settings.name) {
      case RoutesName.navigation:
        return MaterialPageRoute(builder: (context) => const Navigation());
      case RoutesName.duas:
        return MaterialPageRoute(builder: (context) => const Duas());
      case RoutesName.haddiths:
        return MaterialPageRoute(builder: (context) => const Haddiths());
      case RoutesName.motivations:
        return MaterialPageRoute(builder: (context) => const Motivations());
      case RoutesName.accessibility:
        return MaterialPageRoute(builder: (context) =>  AccessibilityInfoPage());
      case RoutesName.admin:
        return MaterialPageRoute(builder: (context) =>  AdminInfoPage());  
        
      case RoutesName.welcome:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case RoutesName.questionnaireIntro:
        return MaterialPageRoute(builder: (context) => const QuestionnaireIntroPage());
      case RoutesName.permissions:
        return MaterialPageRoute(builder: (context) => const PermissionsScreen());
      case RoutesName.questionnaireManager:
        return MaterialPageRoute(builder: (context) => const QuestionnaireManager());
      default:
        // Return a better error page for unhandled routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('404 - Route not found: ${settings.name}', 
                       style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context, RoutesName.welcome
                    ),
                    child: Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
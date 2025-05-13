import 'package:flutter/material.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:purity_path/view/navigation.dart';
import 'package:purity_path/view/lessons/duas.dart';
import 'package:purity_path/view/lessons/haddiths.dart';
import 'package:purity_path/view/lessons/motivations.dart';
import 'package:purity_path/view/navigations/accessibility_info.dart';
import 'package:purity_path/view/navigations/welcome.dart';
import 'package:purity_path/view/navigations/permissions.dart';
import 'package:purity_path/view/navigations/questionnaire_manager.dart';
import 'package:purity_path/view/navigations/questionnaire_intro.dart';

class AppPages {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.navigation:
        return MaterialPageRoute(builder: (_) => Navigation());
      case RoutesName.duas:
        return MaterialPageRoute(builder: (_) => Duas());
      case RoutesName.haddiths:
        return MaterialPageRoute(builder: (_) => Haddiths());
      case RoutesName.motivations:
        return MaterialPageRoute(builder: (_) => Motivations());
      case RoutesName.accessibility:
        return MaterialPageRoute(builder: (_) => AccessibilityInfoPage());
      case RoutesName.welcome:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case RoutesName.questionnaireIntro:
        return MaterialPageRoute(builder: (_) => QuestionnaireIntroPage());
      case RoutesName.permissions:
        return MaterialPageRoute(builder: (_) => PermissionsScreen());
      case RoutesName.questionnaireManager:
        return MaterialPageRoute(builder: (_) => QuestionnaireManager());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}

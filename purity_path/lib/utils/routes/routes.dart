import 'package:flutter/material.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:purity_path/view/navigation.dart';
import 'package:purity_path/view/lessons/duas.dart';
import 'package:purity_path/view/lessons/haddiths.dart';
import 'package:purity_path/view/lessons/motivations.dart';

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
      default:
        return MaterialPageRoute(builder: (_) => Navigation());
   
    }
  }
}

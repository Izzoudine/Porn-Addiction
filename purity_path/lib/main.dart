import 'package:flutter/material.dart';
import 'package:purity_path/utils/routes/routes.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import 'package:purity_path/view/navigations/welcome.dart';

void main() {
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

      initialRoute: RoutesName.welcome,
    );
  }
}

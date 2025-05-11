import 'package:flutter/material.dart';
import 'package:purity_path/view/navigations/history.dart';
import 'package:purity_path/view/navigations/lessons.dart';
import 'package:purity_path/view/navigations/welcome.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purity Path',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Merriweather',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LoginPage(),
    );
  }
}
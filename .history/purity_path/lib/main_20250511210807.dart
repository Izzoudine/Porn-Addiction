import 'package:flutter/material.dart';
import 'package:purity_path/view/navigations/history.dart';
import 'package:purity_path/view/navigations/lessons.dart';
import 'package:purity_path/view/navigations/welcome.dart';
import 'package:purity_path/view/navigations/profile.dart';
import 'package:purity_path/view/navigations/questionnaire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';

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
import 'package:flutter/material.dart';

class Lessons extends StatefulWidget {
  const Lessons({Key? key}) : super(key: key);

  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<Lessons> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Lessons"));
  }
}

import 'package:flutter/material.dart';


class Motivations extends StatefulWidget {
  const Motivations({super.key});

  @override
  _MotivationsPageState createState() => _MotivationsPageState();
}

class _MotivationsPageState extends State<Motivations> {
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Text("Motivations")  ),
    );
  }


}

import 'package:flutter/material.dart';


class Haddiths extends StatefulWidget {
  const Haddiths({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<Haddiths> {
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Text("Haddiths")  ),
    );
  }


}

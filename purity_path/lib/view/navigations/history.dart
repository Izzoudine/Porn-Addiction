import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("History"));
  }
}

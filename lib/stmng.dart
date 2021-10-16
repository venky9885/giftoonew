import 'package:coinmomo/main.dart';
import 'package:coinmomo/splash.dart';
import 'package:flutter/material.dart';

class StateMan extends StatefulWidget {
  const StateMan({Key? key}) : super(key: key);

  @override
  _StateManState createState() => _StateManState();
}

class _StateManState extends State<StateMan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splash();
          }
          return const MyApp();
        },
      ),
    );
  }
}

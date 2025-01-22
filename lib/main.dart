// main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(AlphaSpeakApp());
}

class AlphaSpeakApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlphaSpeak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'vowel_screen.dart';
import 'consonant_screen.dart';
import 'alphabet_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class MainAlphabet extends StatefulWidget {
  final AudioPlayer audioPlayer;

  MainAlphabet({required this.audioPlayer});

  @override
  _MainAlphabetState createState() => _MainAlphabetState();
}

class _MainAlphabetState extends State<MainAlphabet> {
  bool _isLoading = true; // Show loading only at startup

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1)); // 1-second delay
    setState(() {
      _isLoading = false; // Hide loading screen
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alphabet Categories',
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Show Loading Indicator at Startup Only
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent, // Pink loading indicator
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _categoryButton(
                        context,
                        '📖 ALL LETTERS',
                        screenWidth,
                        AlphabetScreen(audioPlayer: widget.audioPlayer)),
                    SizedBox(height: 25),
                    _categoryButton(
                        context, '🔤 VOWELS', screenWidth, VowelScreen()),
                    SizedBox(height: 25),
                    _categoryButton(
                        context, '🅰️ CONSONANTS', screenWidth, ConsonantScreen()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryButton(
      BuildContext context, String category, double screenWidth, Widget screen) {
    return SizedBox(
      width: screenWidth * 0.85,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
        ),
        onPressed: () {
          // Directly navigate without loading
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(
          category,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

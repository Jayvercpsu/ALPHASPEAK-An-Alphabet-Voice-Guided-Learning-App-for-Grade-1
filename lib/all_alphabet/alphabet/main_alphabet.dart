import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../vowels/vowel_screen.dart';
import '../consonants/consonant_screen.dart';
import 'alphabet_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class MainAlphabet extends StatefulWidget {
  final AudioPlayer audioPlayer;

  MainAlphabet({required this.audioPlayer});

  @override
  _MainAlphabetState createState() => _MainAlphabetState();
}

class _MainAlphabetState extends State<MainAlphabet> with TickerProviderStateMixin {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alphabet Categories',
          style: GoogleFonts.berkshireSwash(fontSize: 26, color: Colors.white),
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

          // Animated Fade-in Loading Screen
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent,
              ),
            )
                : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _animatedCategoryButton(
                        context,
                        '📖 ALL LETTERS',
                        screenWidth,
                        AlphabetScreen(audioPlayer: widget.audioPlayer)),
                    SizedBox(height: 25),
                    _animatedCategoryButton(
                        context, '🔤 VOWELS', screenWidth, VowelScreen()),
                    SizedBox(height: 25),
                    _animatedCategoryButton(
                        context, '🅰️ CONSONANTS', screenWidth, ConsonantScreen()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedCategoryButton(
      BuildContext context, String category, double screenWidth, Widget screen) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 30), // Slide effect on load
          child: SizedBox(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
              child: Text(
                category,
                style: GoogleFonts.berkshireSwash(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'alphabet_screen.dart';
import 'pronunciation_checker_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'assets/alphabet.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "ALPHASPEAK: An Alphabet Voice Guided Learning App for Grade 1",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Learn Alphabet Button
                  _buildImageButton(
                    context,
                    text: "Learn Alphabet",
                    imagePath: 'assets/home-screen/abc.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlphabetScreen()),
                      );
                    },
                  ),
                  SizedBox(width: 20),
                  // Pronunciation Checker Button
                  _buildImageButton(
                    context,
                    text: "Pronunciation Checker",
                    imagePath: 'assets/home-screen/voice.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PronunciationCheckerScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Method to Build Buttons with Image
  Widget _buildImageButton(BuildContext context,
      {required String text,
        required String imagePath,
        required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button Image
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Button Text
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
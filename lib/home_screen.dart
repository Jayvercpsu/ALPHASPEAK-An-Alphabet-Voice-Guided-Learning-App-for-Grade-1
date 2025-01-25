import 'package:flutter/material.dart';
import 'alphabet_screen.dart';
import 'matching_letters.dart';

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
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset(
                    'assets/alphabet.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "AlphaSpeak: Alphabet Learning App",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Comic Sans MS',
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
                SizedBox(height: 30),

                // Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // First Row: Learn Alphabet and Matching Letters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureButton(
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
                          _buildFeatureButton(
                            context,
                            text: "Matching Letters",
                            imagePath: 'assets/home-screen/matching.png',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MatchingLettersScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Second Row: Pronunciation Checker
                      _buildFeatureButton(
                        context,
                        text: "Check Pronunciation",
                        imagePath: 'assets/home-screen/voice.png',
                        onPressed: () {
                            MaterialPageRoute(builder: (context) => CheckPronunciationScreen()),
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Method to Build Buttons with Images
  Widget _buildFeatureButton(BuildContext context,
      {required String text, required String imagePath, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 160,
        height: 220,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Comic Sans MS',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main_alphabet.dart';
import 'matching_letters.dart';
import 'check_pronunciation.dart';
import 'word_puzzle.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  HomeScreen({required this.audioPlayer});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _tapPlayer = AudioPlayer(); // For playing tap sound

  @override
  void initState() {
    super.initState();
    _resumeBackgroundMusic();
  }

  Future<void> _resumeBackgroundMusic() async {
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await widget.audioPlayer.resume();
  }

  Future<void> _stopBackgroundMusic() async {
    await widget.audioPlayer.pause();
  }

  Future<void> _playTapSound() async {
    // Play the tap sound
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'), volume: 1.0);
  }

  @override
  void dispose() {
    _tapPlayer.dispose(); // Dispose the tap sound player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate button size to fit two per row
    final buttonWidth = (screenWidth - 60) / 2; // Subtract padding and spacing
    final buttonHeight = buttonWidth * 1.3; // Adjust height proportionally

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      // Slightly stronger opacity
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          for (int i = 0;
                              i < "AlphaSpeak: Alphabet Learning App".length;
                              i++)
                            TextSpan(
                              text: "AlphaSpeak: Alphabet Learning App"[i],
                              style: GoogleFonts.pacifico(
                                fontSize: 30,
                                // Slightly bigger for better visibility
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                // Adds slight spacing for readability
                                color: [
                                  Colors.red,
                                  Colors.orange,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.indigo,
                                  Colors.purple
                                ][i % 7],
                                // Cycle through rainbow colors
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    // Darker shadow for contrast
                                    blurRadius: 8,
                                    offset: Offset(3, 3),
                                  ),
                                  Shadow(
                                    color: Colors.white.withOpacity(0.6),
                                    // Soft outer glow
                                    blurRadius: 10,
                                    offset: Offset(-2, -2),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Features Section
                // Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // First Row: Learn Alphabet and Matching Letters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureButton(
                            context,
                            text: "Learn Alphabet",
                            imagePath: 'assets/home-screen/abc.png',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () async {
                              await _playTapSound();
                              await _stopBackgroundMusic();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainAlphabet(
                                    audioPlayer: widget.audioPlayer,
                                  ),
                                ),
                              );
                              await _resumeBackgroundMusic();
                            },
                          ),
                          _buildFeatureButton(
                            context,
                            text: "Rhyming Words",
                            imagePath: 'assets/home-screen/matching.png',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () async {
                              await _playTapSound();
                              await _stopBackgroundMusic();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchingLettersScreen(
                                    audioPlayer: widget.audioPlayer,
                                  ),
                                ),
                              );
                              await _resumeBackgroundMusic();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Second Row: Check Pronunciation and Word Puzzle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureButton(
                            context,
                            text: "Check Pronunciation",
                            imagePath: 'assets/home-screen/voice.png',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () async {
                              await _playTapSound();
                              await _stopBackgroundMusic();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckPronunciationScreen(
                                    audioPlayer: widget.audioPlayer,
                                  ),
                                ),
                              );
                              await _resumeBackgroundMusic();
                            },
                          ),
                          _buildFeatureButton(
                            context,
                            text: "Word Puzzle",
                            imagePath: 'assets/home-screen/puzzle.png',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () async {
                              await _playTapSound();
                              await _stopBackgroundMusic();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordPuzzleScreen(
                                    audioPlayer: widget
                                        .audioPlayer, // Pass the audioPlayer here
                                  ),
                                ),
                              );
                              await _resumeBackgroundMusic();
                            },
                          ),
                        ],
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
      {required String text,
      required String imagePath,
      required double width,
      required double height,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
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
              height: height * 0.5,
              width: height * 0.5,
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

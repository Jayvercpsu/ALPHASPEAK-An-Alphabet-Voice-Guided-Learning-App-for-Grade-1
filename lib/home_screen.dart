import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'alphabet_screen.dart';
import 'matching_letters.dart';
import 'check_pronunciation.dart';
import 'word_puzzle.dart';

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

                // Title with white background color
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "AlphaSpeak: Alphabet Learning App",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        shadows: [
                          Shadow(
                            color: Colors.blueAccent,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
                                  builder: (context) => AlphabetScreen(
                                    audioPlayer: widget.audioPlayer,
                                  ),
                                ),
                              );
                              await _resumeBackgroundMusic();
                            },
                          ),
                          _buildFeatureButton(
                            context,
                            text: "Matching Letters",
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
                                  builder: (context) => CheckPronunciationScreen(
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
                                    audioPlayer: widget.audioPlayer, // Pass the audioPlayer here
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

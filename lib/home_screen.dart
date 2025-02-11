import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'all_alphabet/alphabet/main_alphabet.dart';
import 'rhyming_words/matching_letters.dart';
import 'check_pronunciation/check_pronunciation.dart';
import 'word_puzzle/word_puzzle.dart';
import 'fill_words/fill_words.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  HomeScreen({required this.audioPlayer});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _tapPlayer = AudioPlayer();

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
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'), volume: 1.0);
  }

  @override
  void dispose() {
    _tapPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 60) / 2;
    final buttonHeight = buttonWidth * 1.3;

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

                // App Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                    child: Text(
                      "AlphaSpeak: Alphabet Learning App",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.berkshireSwash(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Features Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildFeatureRow(
                        context,
                        [
                          _FeatureItem(
                            text: "Learn Alphabet",
                            imagePath: 'assets/home-screen/abc.png',
                            screen: MainAlphabet(audioPlayer: widget.audioPlayer),
                          ),
                          _FeatureItem(
                            text: "Rhyming Words",
                            imagePath: 'assets/home-screen/matching.png',
                            screen: MatchingLettersScreen(audioPlayer: widget.audioPlayer),
                          ),
                        ],
                        buttonWidth,
                        buttonHeight,
                      ),
                      SizedBox(height: 20),
                      _buildFeatureRow(
                        context,
                        [
                          _FeatureItem(
                            text: "Check Pronunciation",
                            imagePath: 'assets/home-screen/voice.png',
                            screen: CheckPronunciationScreen(audioPlayer: widget.audioPlayer),
                          ),
                          _FeatureItem(
                            text: "Word Puzzle",
                            imagePath: 'assets/home-screen/puzzle.png',
                            screen: WordPuzzleScreen(audioPlayer: widget.audioPlayer),
                          ),
                        ],
                        buttonWidth,
                        buttonHeight,
                      ),
                      SizedBox(height: 20),
                      // New Feature: Fill Words
                      _buildFeatureRow(
                        context,
                        [
                          _FeatureItem(
                            text: "Fill Words",
                            imagePath: 'assets/home-screen/fill_in.png',
                            screen: FillWordsScreen(audioPlayer: widget.audioPlayer),
                          ),
                          _FeatureItem(
                            text: "",
                            imagePath: '',
                            screen: Container(), // Empty container to maintain width
                          ),
                        ],
                        buttonWidth,
                        buttonHeight,
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

  // Helper to build feature rows
  Widget _buildFeatureRow(BuildContext context, List<_FeatureItem> features, double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: features.map((feature) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: _buildFeatureButton(
              context,
              text: feature.text,
              imagePath: feature.imagePath,
              width: width,
              height: height,
              screen: feature.screen,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Interactive Feature Button
  Widget _buildFeatureButton(BuildContext context, {required String text, required String imagePath, required double width, required double height, required Widget screen}) {
    return GestureDetector(
      onTap: () async {
        await _playTapSound();
        await _stopBackgroundMusic();
        await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        await _resumeBackgroundMusic();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
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
              style: GoogleFonts.berkshireSwash(
                fontSize: 18,
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

// Data class for features
class _FeatureItem {
  final String text;
  final String imagePath;
  final Widget screen;

  _FeatureItem({required this.text, required this.imagePath, required this.screen});
}

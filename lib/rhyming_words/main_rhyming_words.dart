import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_alphabet/rhyming_words/difficulty/easy_rhyme_word.dart';
import 'package:learn_alphabet/rhyming_words/difficulty/medium_rhyme_word.dart';
import 'package:learn_alphabet/rhyming_words/difficulty/hard_rhyme_word.dart';

class MainRhymingWords extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const MainRhymingWords({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _MainRhymingWordsState createState() => _MainRhymingWordsState();
}

class _MainRhymingWordsState extends State<MainRhymingWords> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final AudioPlayer _tapPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startLoading();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start from bottom
      end: Offset.zero,    // Slide to center
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _playTapSound() async {
    await _tapPlayer.stop(); // Stop previous sound
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));
  }

  void _startGame(String difficulty) {
    _playTapSound();
    Widget screen;

    switch (difficulty) {
      case "Easy":
        screen = EasyRhymeScreen(audioPlayer: widget.audioPlayer);
        break;
      case "Medium":
        screen = MediumRhymeScreen(audioPlayer: widget.audioPlayer);
        break;
      case "Hard":
        screen = HardRhymeScreen(audioPlayer: widget.audioPlayer);
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }


  @override
  void dispose() {
    _tapPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rhyming Words 🎤',
          style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.pinkAccent,
            ),
          )
              : SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding around text
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.8), // Background color with opacity
                    borderRadius: BorderRadius.circular(12), // Optional rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Choose Difficulty",
                    style: GoogleFonts.berkshireSwash(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                _buildDifficultyButton("Easy", Colors.greenAccent),
                _buildDifficultyButton("Medium", Colors.orangeAccent),
                _buildDifficultyButton("Hard", Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String level, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        width: double.infinity, // Full width button
        child: ElevatedButton(
          onPressed: () => _startGame(level),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          child: Text(
            level,
            style: GoogleFonts.berkshireSwash(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

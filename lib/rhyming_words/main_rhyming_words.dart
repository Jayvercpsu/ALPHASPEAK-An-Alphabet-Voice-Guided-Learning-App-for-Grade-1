import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'difficulty/easy_rhyme_word.dart';
import 'difficulty/medium_rhyme_word.dart';
import 'difficulty/hard_rhyme_word.dart';

class RhymingWordsScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const RhymingWordsScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _RhymingWordsScreenState createState() => _RhymingWordsScreenState();
}

class _RhymingWordsScreenState extends State<RhymingWordsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final AudioPlayer _tapPlayer = AudioPlayer();

  int _easyScore = 0;
  int _mediumScore = 0;
  int _hardScore = 0;
  String _selectedDifficulty = 'Easy';

  @override
  void initState() {
    super.initState();
    _startLoading();
    _loadScores();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _easyScore = prefs.getInt('easy_score') ?? 0;
      _mediumScore = prefs.getInt('medium_score') ?? 0;
      _hardScore = prefs.getInt('hard_score') ?? 0;
    });
  }

  int getTotalScore() {
    return _easyScore + _mediumScore + _hardScore;
  }

  Future<void> _playTapSound() async {
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

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) => _loadScores());
  }

  void _resetScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _easyScore = 0;
      _mediumScore = 0;
      _hardScore = 0;
    });

    prefs.setInt('easy_score_rhyme', 0);
    prefs.setInt('medium_score_rhyme', 0);
    prefs.setInt('hard_score_rhyme', 0);
  }

  @override
  void dispose() {
    _tapPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rhyming Words 🎤',
          style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white), // Make back arrow white
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background1.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), // Adjust the opacity here (0.0 - 1.0)
                    BlendMode.darken, // Darken the background
                  ),
                ),
              ),
            ),
          ),

          _isLoading
              ? Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          )
              : SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Difficulty",
                  style: GoogleFonts.berkshireSwash(fontSize: screenHeight * 0.04, color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildDifficultyButton("Easy", Colors.greenAccent, screenWidth),
                _buildDifficultyButton("Medium", Colors.orangeAccent, screenWidth),
                _buildDifficultyButton("Hard", Colors.redAccent, screenWidth),
                SizedBox(height: screenHeight * 0.05),
                _buildScoreBox(screenHeight, screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String level, Color color, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: screenWidth * 0.8,
        child: ElevatedButton(
          onPressed: () => _startGame(level),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            level,
            style: GoogleFonts.berkshireSwash(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBox(double screenHeight, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Total Score: ${getTotalScore()}",
            style: GoogleFonts.berkshireSwash(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "Easy: $_easyScore | Medium: $_mediumScore | Hard: $_hardScore",
            style: GoogleFonts.berkshireSwash(fontSize: screenHeight * 0.025, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

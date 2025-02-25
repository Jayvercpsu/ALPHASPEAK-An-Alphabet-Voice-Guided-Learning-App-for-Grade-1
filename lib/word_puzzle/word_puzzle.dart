import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'easy_word_puzzle.dart';
import 'medium_word_puzzle.dart';
import 'hard_word_puzzle.dart';

class WordPuzzleScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const WordPuzzleScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _WordPuzzleScreenState createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedDifficulty = 'Easy';
  int _easyScore = 0;
  int _mediumScore = 0;
  int _hardScore = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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

  void _startGame(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });

    Widget screen;
    switch (difficulty) {
      case 'Easy':
        screen = EasyWordPuzzleScreen(audioPlayer: widget.audioPlayer, updateScore: _updateScore);
        break;
      case 'Medium':
        screen = MediumWordPuzzleScreen(audioPlayer: widget.audioPlayer, updateScore: _updateScore);
        break;
      case 'Hard':
        screen = HardWordPuzzleScreen(audioPlayer: widget.audioPlayer, updateScore: _updateScore);
        break;
      default:
        screen = EasyWordPuzzleScreen(audioPlayer: widget.audioPlayer, updateScore: _updateScore);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) => _loadScores());
  }

  void _updateScore(int points) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_selectedDifficulty == 'Easy') {
        _easyScore += points;
        prefs.setInt('easy_score', _easyScore);
      } else if (_selectedDifficulty == 'Medium') {
        _mediumScore += points;
        prefs.setInt('medium_score', _mediumScore);
      } else if (_selectedDifficulty == 'Hard') {
        _hardScore += points;
        prefs.setInt('hard_score', _hardScore);
      }
    });
  }

  void _resetScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _easyScore = 0;
      _mediumScore = 0;
      _hardScore = 0;
    });

    prefs.setInt('easy_score', 0);
    prefs.setInt('medium_score', 0);
    prefs.setInt('hard_score', 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Word Puzzle 🎯', style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetScores),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/background1.jpg'), fit: BoxFit.cover),
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Choose Difficulty",
                    style: GoogleFonts.berkshireSwash(fontSize: screenHeight * 0.035, fontWeight: FontWeight.bold, color: Colors.white),
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: screenWidth * 0.8,
        child: ElevatedButton(
          onPressed: () => _startGame(level),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: color,
            elevation: 5,
          ),
          child: Text(
            level,
            style: GoogleFonts.berkshireSwash(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2, offset: Offset(2, 2))],
      ),
      child: Column(
        children: [
          Text(
            "Total Score: ${getTotalScore()}",
            style: GoogleFonts.berkshireSwash(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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

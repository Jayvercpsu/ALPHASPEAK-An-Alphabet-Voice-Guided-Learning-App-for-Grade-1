import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class MediumWordPuzzleScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(int) updateScore;

  MediumWordPuzzleScreen({required this.audioPlayer, required this.updateScore});

  @override
  _MediumWordPuzzleScreenState createState() => _MediumWordPuzzleScreenState();
}

class _MediumWordPuzzleScreenState extends State<MediumWordPuzzleScreen> with SingleTickerProviderStateMixin {
  final List<String> _words = [
    'HOME', 'GAME', 'BOOK', 'WORD', 'TREE', 'FISH', 'STAR', 'MOON', 'WIND', 'BIRD',
    'HAND', 'FEET', 'LAMP', 'DESK', 'DOOR', 'SHIP', 'JUMP', 'FIRE', 'CART', 'DUST',
    'MILK', 'TENT', 'RACE', 'COOK', 'SAND', 'FORK', 'BELL', 'WALL', 'ROCK', 'GIFT'
  ];

  late String _targetWord = ''; // Fixed late initialization
  late List<String> _scrambledLetters;
  List<String> _userWordLetters = [];
  List<Color> _slotColors = [];
  bool _isLoading = true;
  int _score = 0;
  late FlutterTts _flutterTts;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late AudioPlayer _soundPlayer;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _soundPlayer = AudioPlayer();

    _startLoading();
    _initializeTTS();
    _loadScore();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    _initializePuzzle();
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  List<bool?> _isCorrect = [];

  void _initializePuzzle() async {
    setState(() {
      _targetWord = (_words..shuffle()).first;
      _scrambledLetters = _targetWord.split('')..shuffle();
      _userWordLetters = List.filled(_targetWord.length, '');
      _slotColors = List.filled(_targetWord.length, Colors.grey);
      _isLoading = false;
    });

    await Future.delayed(Duration(milliseconds: 500));



    await _flutterTts.speak("Arrange the letters for $_targetWord");
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('medium_score') ?? 0;
    });
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('medium_score', _score);
  }

  void _resetScore() async {
    bool confirmReset = await _showConfirmationDialog();
    if (confirmReset) {
      setState(() {
        _score = 0;
      });
      await _saveScore();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset Score?"),
        content: Text("Are you sure you want to reset your score?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Reset")),
        ],
      ),
    );
  }

  Future<void> _playSound(String soundPath) async {
    await _soundPlayer.stop();
    await _soundPlayer.play(AssetSource(soundPath));
  }

  bool _isPuzzleComplete() {
    return _userWordLetters.join('') == _targetWord;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medium Word Puzzle 🎈',
          style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetScore),
        ],
      ),
      body: Stack(
        children: [
          // Background Image with Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Score: $_score",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildWordSlots(),
                    SizedBox(height: 20),
                    _buildScrambledLetters(),
                    SizedBox(height: 20),
                    _buildResetButton(),
                  ],
                ),
              ),
            ),

          // Confetti Animation
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
              emissionFrequency: 0.05,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildWordSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_targetWord.length, (index) {
        return DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 65,
              height: 75,
              decoration: BoxDecoration(
                color: _userWordLetters[index].isNotEmpty && _userWordLetters[index] == _targetWord[index]
                    ? Colors.blue // Blue Background for Correct Letter
                    : Colors.white, // White for Empty or Incorrect
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _slotColors[index], width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                _userWordLetters[index].isNotEmpty ? _userWordLetters[index] : _targetWord[index],
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _userWordLetters[index].isNotEmpty ? Colors.white : Colors.black12, // Show Outline Letter
                ),
              ),
            );
          },
          onAccept: (letter) async {
            setState(() {
              if (letter == _targetWord[index]) {
                _userWordLetters[index] = letter;
                _scrambledLetters.remove(letter);
                _slotColors[index] = Colors.blue; // Blue Background for Correct
                _playSound('word_puzzle/drop.mp3'); // Drop Sound
              } else {
                _slotColors[index] = Colors.red; // Red Background for Wrong
                _playSound('alphabet-sounds/wrong.mp3'); // Wrong Sound
              }
            });

            // ✅ Add Score Only After Completing the Puzzle
            if (_isPuzzleComplete()) {
              _confettiController.play(); // Confetti Explosion
              await _playSound('stories/sound/win.mp3'); // Win Sound

              setState(() {
                _score += 1; // Add Score Once Only
                _saveScore(); // Save Score to SharedPreferences
              });

              Future.delayed(Duration(seconds: 2), () {
                _initializePuzzle(); // Reset Puzzle
              });
            }
          },
        );
      }),
    );
  }


  Widget _buildScrambledLetters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _scrambledLetters.map((letter) {
        return Draggable<String>(
          data: letter,
          child: _buildLetterTile(letter),
          feedback: _buildLetterTile(letter, isDragging: true),
          childWhenDragging: _buildLetterTile(letter, isFaded: true),
        );
      }).toList(),
    );
  }

  Widget _buildLetterTile(String letter, {bool isDragging = false, bool isFaded = false}) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: isDragging ? Colors.blueAccent.withOpacity(0.8) : isFaded ? Colors.grey[400] : Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _initializePuzzle,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
      child: Text("Next Word", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}


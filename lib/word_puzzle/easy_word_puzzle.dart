import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class EasyWordPuzzleScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(int) updateScore;
  EasyWordPuzzleScreen({required this.audioPlayer, required this.updateScore});

  @override
  _EasyWordPuzzleScreenState createState() => _EasyWordPuzzleScreenState();
}

class _EasyWordPuzzleScreenState extends State<EasyWordPuzzleScreen> with SingleTickerProviderStateMixin {
  final List<String> _words = [
    'CAT', 'DOG', 'SUN', 'HAT', 'BAT', 'CAR', 'BAG', 'BUG', 'PEN', 'MAP', 'CUP', 'TOP',
    'FOX', 'BOX', 'FAN', 'BUS', 'NET', 'JAR', 'LIP', 'NUT', 'OWL', 'PIG', 'RUG', 'WEB',
    'YAK', 'ZOO', 'WAX', 'VAN', 'TUB', 'GUM'
  ];
  late String _targetWord;
  late List<String> _scrambledLetters;
  List<String> _userWordLetters = [];
  List<Color> _slotColors = [];
  bool _isLoading = true;
  int _score = 0;
  late FlutterTts _flutterTts;
  late ConfettiController _confettiController;
  late AudioPlayer _soundPlayer;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _gameCompleted = false; // Track if game is completed

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _soundPlayer = AudioPlayer();
    _startLoading();
    _initializeTTS();
    _loadScore();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _initializePuzzle();
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  List<bool?> _isCorrect = [];

  void _initializePuzzle() async {
    // Prevent TTS and puzzle setup if game is completed
    if (_gameCompleted) return;

    setState(() {
      _targetWord = (_words..shuffle()).first;
      _scrambledLetters = _targetWord.split('')..shuffle();
      _userWordLetters = List.filled(_targetWord.length, '');
      _slotColors = List.filled(_targetWord.length, Colors.grey);
      _isCorrect = List.filled(_targetWord.length, null);
    });

    await _flutterTts.speak("Arrange the letters for $_targetWord");
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('easy_word_score') ?? 0;
      _gameCompleted = _score >= 15; // Check if game is already completed
    });
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('easy_word_score', _score);
  }

  void _resetScore() async {
    bool confirmReset = await _showConfirmationDialog();
    if (confirmReset) {
      setState(() {
        _score = 0;
        _gameCompleted = false;
      });
      await _saveScore();
      _initializePuzzle(); // TTS is already handled here
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Text("Congratulations!", style: GoogleFonts.poppins(fontSize: 24, color: Colors.pinkAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You've completed all 15 puzzles!", style: GoogleFonts.poppins(fontSize: 18)),
            SizedBox(height: 20),
            Image.asset('assets/stories/trophy.gif', width: 100),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text("Back", style: GoogleFonts.poppins(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              _resetScore();
              Navigator.pop(context); // Close dialog
            },
            child: Text("New Game", style: GoogleFonts.poppins(fontSize: 18, color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Easy Word Puzzle 🎈', style: GoogleFonts.poppins(fontSize: 28, color: Colors.white)),
          backgroundColor: Colors.pinkAccent,
          iconTheme: IconThemeData(color: Colors.white),
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Congratulations!", style: GoogleFonts.poppins(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text("You've completed all 15 puzzles!", style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Back to Menu", style: GoogleFonts.poppins(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetScore,
                    child: Text("New Game", style: GoogleFonts.poppins(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Easy Word Puzzle 🎈', style: GoogleFonts.poppins(fontSize: 28, color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetScore),
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

          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Score: $_score/15", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellow)),
                _buildWordSlots(),
                _buildScrambledLetters(),
                _buildResetButton(),
              ],
            ),
        ],
      ),
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
        color: isDragging ? Colors.blue.withOpacity(0.8) : isFaded ? Colors.grey[400] : Colors.blue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
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
                color: _isCorrect[index] == true ? Colors.blue.withOpacity(0.8) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isCorrect[index] == true ? Colors.blue : _slotColors[index],
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _userWordLetters[index].isNotEmpty ? _userWordLetters[index] : _targetWord[index],
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _userWordLetters[index].isNotEmpty ? Colors.white : Colors.black12,
                ),
              ),
            );
          },
          onAccept: (letter) async {
            setState(() {
              if (letter == _targetWord[index]) {
                _userWordLetters[index] = letter;
                _scrambledLetters.remove(letter);
                _slotColors[index] = Colors.blue;
                _isCorrect[index] = true;
                _playSound('word_puzzle/drop.mp3');
              } else {
                _slotColors[index] = Colors.red;
                _isCorrect[index] = false;
                _playSound('alphabet-sounds/wrong.mp3');
              }
            });

            if (_isPuzzleComplete()) {
              _confettiController.play();
              setState(() {
                _score += 1;
              });
              await _saveScore();
              await _playSound('stories/sound/win.mp3');

              if (_score >= 15) {
                setState(() {
                  _gameCompleted = true;
                });
                _showCompletionDialog();
              } else {
                Future.delayed(Duration(seconds: 2), () {
                  _initializePuzzle();
                });
              }
            }
          },
        );
      }),
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
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'score_history.dart';

class MatchingLettersScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  MatchingLettersScreen({required this.audioPlayer});

  @override
  _MatchingLettersScreenState createState() => _MatchingLettersScreenState();
}

class _MatchingLettersScreenState extends State<MatchingLettersScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _targetLetter = 'A';
  List<String> _squareLetters = [];
  Map<String, bool?> _letterStates = {};
  int _score = 0; // Score tracker
  bool _isAnimating = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _randomizeLetters();
    _speakTargetLetter();
    setState(() {
      _isLoading = false;
    });
  }

  void _randomizeLetters() {
    Set<String> lettersSet = {};
    while (lettersSet.length < 4) {
      lettersSet.add(String.fromCharCode(_random.nextInt(26) + 65)); // A-Z
    }

    _squareLetters = lettersSet.toList();
    _targetLetter = _squareLetters[_random.nextInt(4)];
    _letterStates = {
      for (var letter in _squareLetters) letter: null,
    };
    setState(() {});
  }

  Future<void> _speakTargetLetter() async {
    await flutterTts.speak('Select the letter $_targetLetter');
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setSource(AssetSource(path));
      await _audioPlayer.resume();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _handleSelection(String selectedLetter) async {
    if (_isAnimating) return;

    if (selectedLetter == _targetLetter) {
      setState(() {
        _letterStates[selectedLetter] = true;
        _isAnimating = true;
        _score++; // Increment the score for a correct answer
      });
      await _playAudio('alphabet-sounds/correct.mp3');
      await flutterTts.speak('Correct!');
      await Future.delayed(Duration(seconds: 1));
      _randomizeLetters();
      _speakTargetLetter();
      _isAnimating = false;
    } else {
      setState(() {
        _letterStates[selectedLetter] = false;
      });
      await _playAudio('alphabet-sounds/wrong.mp3');
      await flutterTts.speak('Wrong!');
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _letterStates[selectedLetter] = null;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Matching Letters',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Score button in the top-right corner
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreHistoryScreen(
                      initialScore: _score,
                      resetScore: () {
                        setState(() {
                          _score = 0; // Reset the score to 0
                        });
                      },
                    ),
                  ),

                );
              },
              child: Row(
                children: [
                  Icon(Icons.scoreboard, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Score: $_score',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading ? _buildLoadingScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center everything vertically
      crossAxisAlignment: CrossAxisAlignment.center, // Align items to the center horizontally
      children: [
        // Target letter text with background
        Padding(
          padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0), // Adjust top margin
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.orangeAccent], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, // Subtle shadow
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              'Select: $_targetLetter',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),

  Expanded(
          child: Center(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _squareLetters.length,
              itemBuilder: (context, index) {
                return _buildSquareButton(_squareLetters[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSquareButton(String letter) {
    final state = _letterStates[letter];
    final color = state == null
        ? Colors.pinkAccent
        : state
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () => _handleSelection(letter),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

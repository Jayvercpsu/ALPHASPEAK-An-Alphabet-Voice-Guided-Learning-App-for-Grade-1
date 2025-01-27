import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class MatchingLettersScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  MatchingLettersScreen({required this.audioPlayer});

  
  @override
  _MatchingLettersScreenState createState() => _MatchingLettersScreenState();
}

class _MatchingLettersScreenState extends State<MatchingLettersScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _targetLetter = 'A';
  List<String> _squareLetters = [];
  Map<String, bool?> _letterStates = {};
  bool _isAnimating = false;
  bool _isLoading = true; // Show loading screen initially

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  /// Start a 0.5-second loading screen
  Future<void> _startLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _randomizeLetters();
    _speakTargetLetter();
    setState(() {
      _isLoading = false;
    });
  }

  /// Randomize letters in the grid
  void _randomizeLetters() {
    Set<String> lettersSet = {};
    while (lettersSet.length < 4) {
      lettersSet.add(String.fromCharCode(_random.nextInt(26) + 65)); // A-Z
    }

    _squareLetters = lettersSet.toList();
    _targetLetter = _squareLetters[_random.nextInt(4)];
    _letterStates = {
      for (var letter in _squareLetters) letter: null, // Reset states
    };
    setState(() {});
  }

  /// Speak the target letter
  Future<void> _speakTargetLetter() async {
    await flutterTts.speak('Select the letter $_targetLetter');
  }

  /// Play audio for correct/wrong selection
  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setSource(AssetSource(path)); // Set audio source
      await _audioPlayer.resume(); // Play the audio
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  /// Handle user selection
  Future<void> _handleSelection(String selectedLetter) async {
    if (_isAnimating) return;

    if (selectedLetter == _targetLetter) {
      setState(() {
        _letterStates[selectedLetter] = true;
        _isAnimating = true;
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
          style: TextStyle(color: Colors.white), // Set the title text color to white
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set the back button color to white
        backgroundColor: Colors.pinkAccent, // Keep the pink background
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

  /// Build the loading screen
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the main game screen
  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Center the Grid
        Expanded(
          child: Center(
            child: GridView.builder(
              shrinkWrap: true, // Center the grid in available space
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: _squareLetters.length,
              itemBuilder: (context, index) {
                return _buildSquareButton(_squareLetters[index]);
              },
            ),
          ),
        ),
        // "Select the letter" Text Below Grid
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select: $_targetLetter',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
      ],
    );
  }

  /// Square Button with animation and feedback
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
          color: color,
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
              fontSize: 36,
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

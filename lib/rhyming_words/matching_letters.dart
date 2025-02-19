import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'score_history.dart';
import 'package:learn_alphabet/rhyming_words/list_rhyme.dart';

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
  late ConfettiController _confettiController;

  String _targetWord = 'hot';
  List<String> _wordOptions = [];
  Map<String, bool?> _wordStates = {};
  int _score = 0;
  bool _isAnimating = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _loadScore();
    _startLoading();
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('game_score') ?? 0;
    });
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('game_score', _score);
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setSource(AssetSource(path));
      await _audioPlayer.resume();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _startLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _randomizeWords();
    _speakTargetWord();
    setState(() {
      _isLoading = false;
    });
  }

  void _randomizeWords() {
    List<String> keys = correctRhymingWords.keys.toList();
    _targetWord = keys[_random.nextInt(keys.length)];

    String correctWord = correctRhymingWords[_targetWord]!;
    List<String> choices = [correctWord, ...wrongChoices[_targetWord]!];
    choices.shuffle();

    _wordOptions = choices;
    _wordStates = {for (var word in _wordOptions) word: null};

    setState(() {});
  }


  Future<void> _speakTargetWord() async {
    await flutterTts.speak('Find the word that rhymes with $_targetWord');
  }

  Future<void> _handleSelection(String selectedWord) async {
    if (_isAnimating) return;

    await _audioPlayer.stop(); // Stop any currently playing audio

    if (selectedWord == correctRhymingWords[_targetWord]) {
      setState(() {
        _wordStates[selectedWord] = true;
        _isAnimating = true;
        _score++;
      });
      _confettiController.play();
      await _saveScore();
      await _playAudio('alphabet-sounds/correct.mp3');
      await flutterTts.speak('Correct!');

      await Future.delayed(Duration(seconds: 1));
      _randomizeWords();
      _speakTargetWord();
      _isAnimating = false;
    } else {
      setState(() => _wordStates[selectedWord] = false);
      await _playAudio('alphabet-sounds/wrong.mp3'); // Play wrong audio instantly
      await flutterTts.stop(); // Stop any ongoing TTS before speaking
      flutterTts.speak('Wrong!'); // Speak "Wrong!" immediately
      await Future.delayed(Duration(milliseconds: 500));
      setState(() => _wordStates[selectedWord] = null);
    }
  }


  @override
  void dispose() {
    flutterTts.stop();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          'Rhyme Words ',
          style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScoreHistoryScreen(
                    initialScore: _score,
                    resetScore: _resetScore,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Score: $_score', // ✅ Clickable score
                style: GoogleFonts.berkshireSwash(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ✅ Text color pink for contrast
                ),
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white), // ✅ Set back button color to pink
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background1.jpg', fit: BoxFit.cover),
          ),
          if (_isLoading)
            _buildLoadingScreen()
          else
            _buildGameScreen(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
        ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.pinkAccent.withOpacity(0.8), // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Text(
            'Find the word that rhymes with:',
            style: GoogleFonts.berkshireSwash(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(3, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _targetWord,
                style: GoogleFonts.berkshireSwash(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.volume_up, size: 40, color: Colors.pinkAccent),
                onPressed: () => _speakTargetWord(),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: _wordOptions.length,
          itemBuilder: (context, index) {
            return _buildWordButton(_wordOptions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildWordButton(String word) {
    final state = _wordStates[word];
    final color = state == null
        ? Colors.pinkAccent
        : state
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () => _handleSelection(word),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            word,
            style: GoogleFonts.berkshireSwash(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _resetScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_score');
    setState(() {
      _score = 0;
    });
  }
}

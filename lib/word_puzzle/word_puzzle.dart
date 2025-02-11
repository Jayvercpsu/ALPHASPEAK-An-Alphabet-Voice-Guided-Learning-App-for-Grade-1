import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class WordPuzzleScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  WordPuzzleScreen({required this.audioPlayer});

  @override
  _WordPuzzleScreenState createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedDifficulty = 'Easy';
  final Map<String, List<String>> _wordsByDifficulty = {
    'Easy': ['CAT', 'DOG', 'HAT'],
    'Medium': ['HOME', 'GAME', 'WORD', 'BOOK'],
    'Hard': ['PUZZLE', 'WIDGET', 'FLUTTER', 'BUTTON', 'MOBILE', 'SCREEN'],
  };

  late String _targetWord;
  late List<String> _scrambledLetters;
  List<String> _userWordLetters = [];
  List<Color> _slotColors = [];
  bool _loading = true;
  bool _hasPlayedSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.stop();
    _initializePuzzle();
    _simulateLoading();
    _playTutorial();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _loading = false;
    });
  }

  void _initializePuzzle() {
    final words = _wordsByDifficulty[_selectedDifficulty]!;
    final randomIndex = Random().nextInt(words.length);
    _targetWord = words[randomIndex];
    _scrambledLetters = _targetWord.split('')..shuffle();
    _userWordLetters = List.filled(_targetWord.length, '');
    _slotColors = List.filled(_targetWord.length, Colors.grey);
    _hasPlayedSuccess = false;
  }

  Future<void> _playAudio(String path) async {
    try {
      await widget.audioPlayer.stop(); // Stop any currently playing sound
      await widget.audioPlayer.seek(Duration.zero); // Reset position
      await widget.audioPlayer.setSource(AssetSource(path));
      await widget.audioPlayer.resume();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }


  Future<void> _playTutorial() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak("Welcome to the Word Puzzle Game! Drag and drop the letters into the correct boxes to form a word.");
  }

  bool _isPuzzleComplete() {
    if (!_userWordLetters.contains('')) { // Only check when all slots are filled
      return _userWordLetters.join('') == _targetWord;
    }
    return false;
  }



  Future<void> _provideEncouragement() async {
    int placedLetters = _userWordLetters.where((letter) => letter.isNotEmpty).length;
    if (placedLetters == _targetWord.length - 1) {
      await _flutterTts.speak("Almost done!");
    } else {
      await _flutterTts.speak("Nice!");
    }
  }

  Future<void> _showCompletionDialog() async {
    if (_hasPlayedSuccess) return; // Exit if already played

    _hasPlayedSuccess = true; // Set flag to prevent multiple plays

    await _playAudio('word_puzzle/success.mp3'); // Play success sound
    await Future.delayed(Duration(milliseconds: 500)); // Ensure TTS doesn't overlap

    await _flutterTts.speak("Awesome! You solved it! Let's do another!");

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _initializePuzzle();
    });

    _hasPlayedSuccess = false; // Reset for next word
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Puzzle', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _loading ? _buildLoadingScreen() : _buildMainScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)),
          SizedBox(height: 20),
          Text(
            'Loading Puzzle...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                  return ElevatedButton(
                    onPressed: () => setState(() {
                      _selectedDifficulty = difficulty;
                      _initializePuzzle();
                      _playTutorial();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDifficulty == difficulty ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildWordSlots(),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _scrambledLetters.map((letter) {
                return Draggable<String>(
                  data: letter,
                  child: _buildLetterTile(letter, false),
                  feedback: _buildLetterTile(letter, true),
                  childWhenDragging: _buildLetterTile(letter, false, faded: true),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializePuzzle();
                });
              },
              child: Text("Reset Puzzle"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLetterTile(String letter, bool isFeedback, {bool faded = false}) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: isFeedback ? Colors.blue.withOpacity(0.8) : faded ? Colors.grey[400] : Colors.blue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _slotColors[index], width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                _userWordLetters[index].isNotEmpty ? _userWordLetters[index] : '',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
          onAccept: (letter) async {
            setState(() {
              if (letter == _targetWord[index]) {
                _userWordLetters[index] = letter;
                _scrambledLetters.remove(letter);
                _slotColors[index] = Colors.green;
              }
            });

            await _provideEncouragement();

            if (_isPuzzleComplete()) {
              _showCompletionDialog();
            }
          },
        );
      }),
    );
  }
}

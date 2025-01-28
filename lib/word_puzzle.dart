import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class WordPuzzleScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  WordPuzzleScreen({required this.audioPlayer});

  @override
  _WordPuzzleScreenState createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  String _selectedDifficulty = 'Easy';

  final Map<String, List<String>> _wordsByDifficulty = {
    'Easy': ['CAT', 'DOG', 'HAT'],
    'Medium': ['HOME', 'GAME', 'WORD', 'BOOK'],
    'Hard': ['PUZZLE', 'WIDGET', 'FLUTTER', 'BUTTON', 'MOBILE', 'SCREEN'],
  };

  late String _targetWord;
  late List<String> _scrambledLetters;
  List<String> _userWordLetters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.stop(); // Stop any background audio
    _initializePuzzle();
    _simulateLoading(); // Simulate loading before showing the main screen
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
    _userWordLetters = List.filled(_targetWord.length, ''); // Empty slots
  }

  Future<void> _playAudio(String path) async {
    try {
      await widget.audioPlayer.setSource(AssetSource(path));
      await widget.audioPlayer.resume();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    super.dispose();
  }

  bool _isPuzzleComplete() {
    return _userWordLetters.join('') == _targetWord;
  }

  Future<void> _showCompletionDialog() async {
    await _playAudio('success.mp3');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You completed the puzzle!'),
                Text('The word was: $_targetWord'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializePuzzle(); // Reset the puzzle
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Puzzle', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: _loading ? _buildLoadingScreen() : _buildMainScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Loading Puzzle...',
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
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDifficulty == difficulty
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_targetWord.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outlined text
                            Text(
                              _targetWord[index],
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 1.5
                                  ..color = Colors.black54,
                              ),
                            ),
                            // Filled text (only for letters already guessed)
                            Text(
                              _userWordLetters[index].isNotEmpty
                                  ? _userWordLetters[index]
                                  : '',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                );
              },
              onAccept: (letter) async {
                setState(() {
                  int emptyIndex =
                  _userWordLetters.indexWhere((slot) => slot.isEmpty);
                  if (emptyIndex != -1) {
                    _userWordLetters[emptyIndex] = letter;
                    _scrambledLetters.remove(letter);
                    if (_isPuzzleComplete()) {
                      _showCompletionDialog();
                    }
                  }
                });
                await _playAudio('drop.mp3');
              },
            ),
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
              child: Text('Reset Puzzle'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLetterTile(String letter, bool isFeedback, {bool faded = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isFeedback
            ? Colors.blue.withOpacity(0.8)
            : faded
            ? Colors.grey[400]
            : Colors.blue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

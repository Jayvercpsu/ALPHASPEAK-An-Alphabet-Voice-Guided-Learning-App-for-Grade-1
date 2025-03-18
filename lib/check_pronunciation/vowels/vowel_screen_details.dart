import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';

class VowelScreenDetails extends StatefulWidget {
  final String vowel;

  VowelScreenDetails({required this.vowel});

  @override
  _VowelScreenDetailsState createState() => _VowelScreenDetailsState();
}

class _VowelScreenDetailsState extends State<VowelScreenDetails> {
  late FlutterTts flutterTts;
  late stt.SpeechToText _speechToText;
  bool _speechEnabled = false;
  String _spokenWord = '';
  Map<String, int> _countdowns = {};
  String _currentWord = '';
  bool _showMic = false;
  late ConfettiController _confettiController;
  int _totalScore = 0;
  int _countdown = 0;
  final Map<String, List<String>> vowelWords = {
    '/a/': [
      'cat', 'bat', 'sat', 'mat', 'rat', 'hat', 'pat', 'chat', 'flat', 'that',
      'tap', 'lap', 'snap', 'trap', 'map', 'cap', 'clap', 'nap', 'gap', 'sap',
      'rap', 'slap', 'crap', 'wrap', 'scrap', 'flap', 'snap', 'strap', 'crack', 'track'
    ],
    '/e/': [
      'pen', 'ten', 'hen', 'net', 'pet', 'vet', 'set', 'bet', 'let', 'met',
      'get', 'wet', 'jet', 'yet', 'debt', 'fret', 'sweat', 'regret', 'upset', 'reset',
      'forget', 'budget', 'velvet', 'helmet', 'magnet', 'gadget', 'racket', 'jacket', 'packet', 'blanket'
    ],
    '/i/': [
      'pin', 'win', 'fin', 'bin', 'tin', 'sin', 'skin', 'grin', 'chin', 'spin',
      'thin', 'begin', 'within', 'ruin', 'cousin', 'villain', 'pudding', 'chicken', 'hidden', 'kitten',
      'mittens', 'ridden', 'sitting', 'bitten', 'written', 'quitting', 'spitting', 'splitting', 'hitting', 'fitting'
    ],
    '/o/': [
      'dog', 'log', 'fog', 'jog', 'hog', 'bog', 'frog', 'clog', 'smog', 'slog',
      'job', 'mob', 'sob', 'cob', 'rob', 'knob', 'blob', 'slob', 'fob', 'bob',
      'nod', 'rod', 'cod', 'mod', 'prod', 'squad', 'broad', 'plod', 'trodden', 'shod'
    ],
    '/u/': [
      'mud', 'hug', 'tub', 'sub', 'rub', 'cup', 'pup', 'up', 'sum', 'gum',
      'hum', 'bump', 'jump', 'pump', 'plump', 'dump', 'stump', 'grump', 'thump', 'rump',
      'chump', 'lump', 'slump', 'crump', 'rumpus', 'mumps', 'trump', 'hump', 'stump', 'dumb'
    ],
  };


  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _initializeTTS();
    _initializeSpeech();
    _initializeCountdowns();
    _loadScore();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _initializeTTS() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.2);
    flutterTts.setSpeechRate(0.5);
    flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _initializeSpeech() async {
    _speechToText = stt.SpeechToText();
    _speechEnabled = await _speechToText.initialize();
  }

  void _initializeCountdowns() {
    List<String> words = vowelWords[widget.vowel] ?? [];
    for (var word in words) {
      _countdowns[word] = 0;
    }
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalScore = prefs.getInt('score_${widget.vowel}') ?? 0;
    });
  }

  Future<void> _updateScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalScore += 1;
    });
    await prefs.setInt('score_${widget.vowel}', _totalScore);
  }

  void _startCountdown(String word) {
    setState(() {
      _currentWord = word;
      _countdowns[word] = 3;
      _spokenWord = '';
      _showMic = false; // ✅ Hide mic initially
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdowns[word] = _countdowns[word]! - 1;
      });

      if (_countdowns[word] == 0) {
        timer.cancel();
        _speak("Say the word: $word").then((_) {
          setState(() {
            _showMic = true; // ✅ Mic appears AFTER TTS finishes
          });
          _startListening(word);
        });
      }
    });
  }



  void _startListening(String word) async {
    setState(() {
      _showMic = true;
      _spokenWord = 'Listening...'; // Show "Listening..." initially
      _countdown = 0; // Reset countdown initially
    });

    if (!_speechToText.isAvailable) {
      await _speechToText.initialize();
    }

    // Start listening
    _speechToText.listen(
      onResult: (result) {
        String recognized = result.recognizedWords.toLowerCase();
        if (recognized.isNotEmpty && _spokenWord != recognized) {
          _speechToText.stop(); // Stop listening immediately when something is recognized
          setState(() {
            _spokenWord = recognized; // Set recognized word
            _countdown = 0; // Reset countdown after recognition
          });
          _checkPronunciation(word, recognized); // Check pronunciation
        }
      },
      localeId: 'en_US',
    );

    // Wait for 5 seconds of listening, then start the countdown
    Future.delayed(Duration(seconds: 5), () {
      if (_spokenWord == 'Listening...' && _showMic) { // Still listening after 5 seconds and no word recognized
        _speechToText.stop(); // Stop the listening after 5 seconds of inactivity

        // Start countdown from 5
        setState(() {
          _countdown = 5;
        });

        // Start countdown logic
        Timer.periodic(Duration(seconds: 1), (timer) {
          if (_countdown > 0) {
            setState(() {
              _countdown--; // Reduce countdown each second
            });
          } else {
            timer.cancel(); // Stop the timer
            setState(() {
              _spokenWord = 'Try again'; // Display "Try again" if no word was spoken
              _showMic = false; // Stop glowing mic after countdown ends
            });
          }
        });
      }
    });
  }





  void _checkPronunciation(String word, String recognizedWord) async {
    if (!mounted) return; // ✅ Prevent UI updates if widget is disposed

    if (recognizedWord == word.toLowerCase()) {
      _displayFeedback('Correct! 🎉', Colors.green, "Correct! Good Job!", 'alphabet-sounds/correct.mp3');
      _confettiController.play();
      _updateScore();
    } else {
      _displayFeedback('Incorrect! ❌ Try again.', Colors.red, "Incorrect! Please try again.", 'alphabet-sounds/wrong.mp3');

      // ✅ Small delay before restarting listening to prevent instant repeat
      Future.delayed(Duration(milliseconds: 500), () => _startListening(word));
    }
  }

  void _displayFeedback(String message, Color color, String ttsMessage, String sound) async {
    if (!mounted) return;

    setState(() {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ✅ Clear previous message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: color,
          duration: Duration(seconds: 2),
        ),
      );
    });

    _speak(ttsMessage);
    await _audioPlayer.play(AssetSource(sound));
  }




  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _currentWordIndex = 0;

  void _nextWord() {
    setState(() {
      if (_currentWordIndex < (vowelWords[widget.vowel]?.length ?? 1) - 1) {
        _currentWordIndex++;
        _spokenWord = ''; // Reset spoken word
        _startCountdown(vowelWords[widget.vowel]![_currentWordIndex]);
      }
    });
  }

  void _prevWord() {
    setState(() {
      if (_currentWordIndex > 0) {
        _currentWordIndex--;
        _spokenWord = ''; // Reset spoken word
        _startCountdown(vowelWords[widget.vowel]![_currentWordIndex]);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    List<String> words = vowelWords[widget.vowel] ?? [];
    String currentWord = words[_currentWordIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent, // Pink accent background
        iconTheme: IconThemeData(color: Colors.white), // Black icons
        title: Text(
          '${widget.vowel} Vowel Words',
          style: GoogleFonts.poppins(fontSize: 28, color: Colors.white), // Black text
        ),
      ),
      body: Stack(
        children: [
          // Background Image (kept intact)
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Content over the background
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The current word display with improved size and style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding for better alignment
                child: Container(
                  padding: EdgeInsets.all(10), // Padding inside the container to create space around the text
                  decoration: BoxDecoration(
                    color: Colors.white, // Solid white background for the container
                    borderRadius: BorderRadius.circular(15), // Rounded corners for the background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Subtle shadow behind the container
                        offset: Offset(2, 4), // Position of the shadow
                        blurRadius: 6, // Blurring of the shadow for a soft look
                      ),
                    ],
                  ),
                  child: Text(
                    currentWord,
                    textAlign: TextAlign.center, // Center the text
                    style: GoogleFonts.poppins(
                      fontSize: 50, // Large font size
                      fontWeight: FontWeight.normal, // Removed bold styling
                      color: Colors.black, // Black text
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.grey.shade600, // Subtle shadow for text
                          offset: Offset(3, 3), // Offset to create a lifted effect
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30), // Spacing between the word and the mic/button
              // Word tile including the countdown and mic icon
              _wordTile(currentWord),
              SizedBox(height: 20), // Spacing between buttons and word tile
              // Row of navigation buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0), // Padding for the buttons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _prevWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Black button background
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Increased padding for button size
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        "Previous",
                        style: GoogleFonts.poppins(fontSize: 20, color: Colors.black), // White text
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nextWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Black button background
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Increased padding for button size
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        "Next",
                        style: GoogleFonts.poppins(fontSize: 20, color: Colors.black), // White text
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _wordTile(String word) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
              onPressed: () => _speak(word),
            ),
            title: Text(
              word,
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
            ),
            trailing: ElevatedButton(
              onPressed: () => _startCountdown(word),
              child: _currentWord == word && _countdowns[word]! > 0
                  ? Text(
                '${_countdowns[word]}',
                style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Speak', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_currentWord == word)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Show countdown if it's greater than 0
                  if (_countdown > 0)
                    AnimatedScale(
                      scale: 1.5,
                      duration: Duration(milliseconds: 300), // Scale effect
                      child: Text(
                        '$_countdown',
                        style: GoogleFonts.poppins(fontSize: 50, color: Colors.pinkAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Show the spoken word if it's not empty and it's not "Try again"
                  if (_spokenWord.isNotEmpty && _spokenWord != 'Try again' && !_spokenWord.startsWith("Say the word"))
                    Text(
                      _spokenWord,
                      style: GoogleFonts.poppins(fontSize: 20, color: Colors.pinkAccent),
                      textAlign: TextAlign.center,
                    ),
                  // Show "Try again" if the user didn't speak after countdown
                  if (_spokenWord == 'Try again')
                    Text(
                      _spokenWord,
                      style: GoogleFonts.poppins(fontSize: 20, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  // Show "Listening..." when mic is active and no word is recognized
                  if (_showMic && _spokenWord == 'Listening...')
                    AnimatedOpacity(
                      opacity: _showMic ? 1.0 : 0.0, // Animate the "Listening..." text
                      duration: Duration(milliseconds: 500),

                    ),
                  // Glowing mic
                  AvatarGlow(
                    glowColor: Colors.pinkAccent,
                    animate: _showMic, // Mic glows while listening
                    child: Icon(Icons.mic, size: 40, color: Colors.pinkAccent),
                  ),
                ],
              ),
            ),

        ],
      ),
    );
  }

}

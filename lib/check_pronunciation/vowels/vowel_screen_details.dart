import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';
import 'dart:async';


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

  final Map<String, List<String>> vowelWords = {
    '/a/': ['cat', 'bat', 'sat', 'mat', 'rat', 'hat'],
    '/e/': ['pen', 'ten', 'hen', 'net', 'pet', 'vet'],
    '/i/': ['pin', 'win', 'fin', 'bin', 'tin', 'sin'],
    '/o/': ['dog', 'log', 'fog', 'jog', 'hog', 'bog'],
    '/u/': ['mud', 'hug', 'tub', 'sub', 'rub', 'cup'],
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _initializeTTS();
    _initializeSpeech();
    _initializeCountdowns();
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

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _startCountdown(String word) {
    setState(() {
      _currentWord = word;
      _countdowns[word] = 3;
      _spokenWord = '';
      _showMic = false;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdowns[word] = _countdowns[word]! - 1;
      });

      if (_countdowns[word] == 0) {
        timer.cancel();
        setState(() {
          _showMic = true;
        });
        _startListening(word);
      }
    });
  }

  void _startListening(String word) async {
    setState(() {
      _showMic = true;
      _spokenWord = '';
    });

    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _spokenWord = result.recognizedWords;
          });

          if (result.finalResult) {
            _checkPronunciation(word);
          }
        },
        localeId: 'en_US',
      );

      Timer.periodic(Duration(seconds: 1), (timer) {
        if (!_showMic) {
          timer.cancel();
        }

        if (_spokenWord.isNotEmpty) {
          setState(() {
            _showMic = true;
          });
        }

        if (timer.tick == 10 && _spokenWord.isEmpty) {
          timer.cancel();
          _speechToText.stop();
          setState(() {
            _showMic = false;
          });
          _showMessage("Time's up! Try again.", Colors.red);
        }
      });
    }
  }

  void _checkPronunciation(String word) {
    if (_spokenWord.toLowerCase() == word.toLowerCase()) {
      _showMessage('Correct! 🎉', Colors.green);
      _confettiController.play();
    } else {
      _showMessage('Incorrect! Try again.', Colors.red);
      Future.delayed(Duration(seconds: 2), () {
        _startListening(word); // Automatically restart if wrong
      });
    }

    setState(() {
      _showMic = false;
    });
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

  @override
  Widget build(BuildContext context) {
    List<String> words = vowelWords[widget.vowel] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.vowel} Vowel Words',
          style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background1.jpg', fit: BoxFit.cover),
          ),
          ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                widget.vowel,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              Column(
                children: words.map((word) => _wordTile(word)).toList(),
              ),
            ],
          ),
          if (_showMic)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic,
                      size: _spokenWord.isNotEmpty ? 120 : 100,
                      color: _spokenWord.isNotEmpty ? Colors.green : Colors.redAccent,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _spokenWord.isEmpty ? "Waiting..." : _spokenWord,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: _spokenWord.toLowerCase() == _currentWord.toLowerCase()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _speechToText.stop();
                        setState(() {
                          _showMic = false;
                        });
                      },
                      child: Text("Stop"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wordTile(String word) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: Icon(Icons.volume_up, color: Colors.pinkAccent),
        title: Text(
          word,
          style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
        ),
        trailing: ElevatedButton(
          onPressed: () => _startCountdown(word),
          child: _currentWord == word && _countdowns[word]! > 0
              ? Text(
            '${_countdowns[word]}',
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: Colors.white,
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

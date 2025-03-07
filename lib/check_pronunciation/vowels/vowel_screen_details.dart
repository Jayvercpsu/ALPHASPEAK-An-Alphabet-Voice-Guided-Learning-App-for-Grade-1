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
    await _speechToText.listen(
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

    Timer(Duration(seconds: 10), () {
      if (_spokenWord.isEmpty) {
        _speechToText.stop();
        setState(() {
          _showMic = false;
        });
        _showMessage("Time's up! Try again.", Colors.red);
      }
    });
  }

  void _checkPronunciation(String word) async {
    if (_spokenWord.toLowerCase() == word.toLowerCase()) {
      _showMessage('Correct! 🎉', Colors.green);
      _confettiController.play();
      await flutterTts.speak('Correct!');
    } else {
      _showMessage('Incorrect! Try again.', Colors.red);
      await flutterTts.speak('Incorrect! Try again.');
    }

    setState(() {
      _countdowns[word] = 0;
      _currentWord = '';
      _showMic = false;
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.berkshireSwash(fontSize: 18, color: Colors.white),
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
          style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background1.jpg', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
          ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                widget.vowel,
                textAlign: TextAlign.center,
                style: GoogleFonts.berkshireSwash(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up, size: 50, color: Colors.pinkAccent),
                onPressed: () => _speak(widget.vowel),
              ),
              SizedBox(height: 20),
              Column(
                children: words.map((word) => _wordTile(word)).toList(),
              ),
              if (_showMic)
                Center(
                  child: Icon(
                    Icons.mic,
                    size: 100,
                    color: Colors.redAccent,
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
      child: ListTile(
        leading: Icon(Icons.volume_up, color: Colors.pinkAccent),
        title: Text(
          word,
          style: GoogleFonts.berkshireSwash(fontSize: 24, color: Colors.black),
        ),
        trailing: ElevatedButton(
          onPressed: () => _startCountdown(word),
          child: _currentWord == word && _countdowns[word]! > 0
              ? Text(
            '${_countdowns[word]}',
            style: GoogleFonts.berkshireSwash(
              fontSize: 24,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, color: Colors.white),
              SizedBox(width: 5),
              Text('Speak', style: GoogleFonts.berkshireSwash(fontSize: 18, color: Colors.white)),
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

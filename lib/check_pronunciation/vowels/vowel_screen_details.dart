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

  final Map<String, List<String>> vowelWords = {
    '/a/': ['cat', 'bat', 'sat', 'mat', 'rat', 'hat'],
    '/e/': ['pen', 'ten', 'hen', 'net', 'pet', 'vet'],
    '/i/': ['pin', 'win', 'fin', 'bin', 'tin', 'sin'],
    '/o/': ['dog', 'log', 'fog', 'jog', 'hog', 'bog'],
    '/u/': ['mud', 'hug', 'tub', 'sub', 'rub', 'cup'],
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
      _totalScore = prefs.getInt('vowel_score') ?? 0;
    });
  }

  Future<void> _updateScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalScore += 1;
    });
    await prefs.setInt('vowel_score', _totalScore);
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
      _spokenWord = '';
    });

    if (!_speechToText.isAvailable) {
      await _speechToText.initialize();
    }

    _speechToText.listen(
      onResult: (result) {
        String recognized = result.recognizedWords.toLowerCase();
        if (recognized.isNotEmpty && _spokenWord != recognized) {
          _speechToText.stop(); // ✅ Stop listening immediately to prevent duplicate triggers
          setState(() {
            _spokenWord = recognized;
          });
          _checkPronunciation(word, recognized);
        }
      },
      localeId: 'en_US',
    );
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
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 30),
                SizedBox(width: 5),
                Text(
                  '$_totalScore',
                  style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
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
                  if (_spokenWord.isNotEmpty && !_spokenWord.startsWith("Say the word"))
                    Text(
                      _spokenWord,
                      style: GoogleFonts.poppins(fontSize: 20, color: Colors.pinkAccent),
                      textAlign: TextAlign.center,
                    ),
                  AvatarGlow(
                    glowColor: Colors.pinkAccent,
                    animate: _showMic, // ✅ Mic glows while listening
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

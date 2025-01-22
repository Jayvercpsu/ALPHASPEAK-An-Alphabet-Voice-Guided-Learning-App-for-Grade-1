// pronunciation_checker_screen.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PronunciationCheckerScreen extends StatefulWidget {
  @override
  _PronunciationCheckerScreenState createState() =>
      _PronunciationCheckerScreenState();
}

class _PronunciationCheckerScreenState
    extends State<PronunciationCheckerScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _feedback = '';
  String _currentLetter = 'A'; // Default letter to check.

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _feedback = '';
    });

    await _speechToText.listen(onResult: (result) {
      String userInput = result.recognizedWords;
      setState(() {
        _feedback = userInput.toLowerCase() == _currentLetter.toLowerCase()
            ? 'Correct'
            : 'Incorrect';
      });
    });

    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pronunciation Checker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Say: $_currentLetter',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? null : _startListening,
              child: Text(_isListening ? 'Listening...' : 'Start Speaking'),
            ),
            SizedBox(height: 20),
            Text(
              _feedback,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _feedback == 'Correct' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

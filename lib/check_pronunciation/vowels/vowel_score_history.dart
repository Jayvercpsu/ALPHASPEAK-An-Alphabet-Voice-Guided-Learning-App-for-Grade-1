import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class VowelScoreHistory extends StatefulWidget {
  @override
  _VowelScoreHistoryState createState() => _VowelScoreHistoryState();
}

class _VowelScoreHistoryState extends State<VowelScoreHistory> {
  Map<String, int> _scores = {'/a/': 0, '/e/': 0, '/i/': 0, '/o/': 0, '/u/': 0};
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Tap Sound Player

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _loadScores();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose(); // Dispose Tap Sound Player
    super.dispose();
  }

  Future<void> _loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _scores = {
        '/a/': prefs.getInt('score_/a/') ?? 0,
        '/e/': prefs.getInt('score_/e/') ?? 0,
        '/i/': prefs.getInt('score_/i/') ?? 0,
        '/o/': prefs.getInt('score_/o/') ?? 0,
        '/u/': prefs.getInt('score_/u/') ?? 0,
      };
    });
  }

  Future<void> _resetScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('score_/a/');
    await prefs.remove('score_/e/');
    await prefs.remove('score_/i/');
    await prefs.remove('score_/o/');
    await prefs.remove('score_/u/');
    setState(() {
      _scores = {'/a/': 0, '/e/': 0, '/i/': 0, '/o/': 0, '/u/': 0};
    });
    _confettiController.play();
  }


  Future<void> _playTapSound() async {
    await _audioPlayer.stop(); // Stop Previous Sound
    await _audioPlayer
        .play(AssetSource('alphabet-sounds/tap.mp3')); // Play Tap Sound
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Reset',
          style: GoogleFonts.poppins(fontSize: 22, color: Colors.pinkAccent),
        ),
        content: Text(
          'Are you sure you want to reset your score?',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playTapSound(); // Tap Sound on Cancel
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.pinkAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScores();
            },
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Vowel Score History',
            style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
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
                blastDirection: pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Total Score',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${_scores.values.reduce((a, b) => a + b)}',
                    style: GoogleFonts.poppins(
                      fontSize: 60,
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset Score',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

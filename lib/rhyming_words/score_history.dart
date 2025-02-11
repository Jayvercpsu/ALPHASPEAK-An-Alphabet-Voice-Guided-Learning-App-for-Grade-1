import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';


class ScoreHistoryScreen extends StatefulWidget {
  final int initialScore;
  final Function resetScore; // Callback for resetting the score in the parent widget

  ScoreHistoryScreen({required this.initialScore, required this.resetScore});

  @override
  _ScoreHistoryScreenState createState() => _ScoreHistoryScreenState();
}

class _ScoreHistoryScreenState extends State<ScoreHistoryScreen> {
  late int _currentScore; // Local state to manage the score
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentScore = widget.initialScore; // Initialize the score
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
  }

  Future<void> _playTapSound() async {
    await _audioPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));
  }

  void _resetScore() {
    setState(() {
      _currentScore = 0; // Reset the local score
    });
    widget.resetScore(); // Call the parent callback to reset the score globally
    _confettiController.play();
    _showSuccessMessage(); // Show success message
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Score has been reset successfully!',
          style: GoogleFonts.berkshireSwash(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Reset',
            style: GoogleFonts.berkshireSwash(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to reset the score?',
            style: GoogleFonts.berkshireSwash(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resetScore(); // Reset the score
              },
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
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
        title: Text(
          'Score History 🏆',
          style: GoogleFonts.berkshireSwash(fontSize: 26, color: Colors.white),
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
                Icon(Icons.emoji_events, size: 100, color: Colors.yellowAccent),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Current Score:',
                        style: GoogleFonts.berkshireSwash(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$_currentScore',
                        style: GoogleFonts.berkshireSwash(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildButton('Reset Score', Colors.redAccent, Icons.refresh, () async {
                  await _playTapSound();
                  _showConfirmationDialog();
                }),
                SizedBox(height: 30),
                _buildButton('Back to Game', Colors.blueAccent, Icons.arrow_back, () async {
                  await _playTapSound();
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.berkshireSwash(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

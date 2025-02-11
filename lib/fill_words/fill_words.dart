import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class FillWordsScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  FillWordsScreen({required this.audioPlayer});

  @override
  _FillWordsScreenState createState() => _FillWordsScreenState();
}

class _FillWordsScreenState extends State<FillWordsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playAudio(String assetPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fill Words",
          style: GoogleFonts.berkshireSwash(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "Choose a Category",
                style: GoogleFonts.berkshireSwash(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Poem Button
              _buildFeatureButton(
                context,
                text: "Poem",
                imagePath: 'assets/home-screen/poem.png',
                audioPath: 'fill-words/poem.mp3',
              ),

              SizedBox(height: 20),

              // Songs Button
              _buildFeatureButton(
                context,
                text: "Songs",
                imagePath: 'assets/home-screen/song.png',
                audioPath: 'fill-words/song.mp3',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature Button Builder
  Widget _buildFeatureButton(BuildContext context, {required String text, required String imagePath, required String audioPath}) {
    return GestureDetector(
      onTap: () => _playAudio(audioPath),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80, height: 80),
            SizedBox(height: 10),
            Text(
              text,
              style: GoogleFonts.berkshireSwash(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

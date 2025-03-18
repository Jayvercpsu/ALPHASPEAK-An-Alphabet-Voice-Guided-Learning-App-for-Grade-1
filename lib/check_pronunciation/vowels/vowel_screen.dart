import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'vowel_screen_details.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vowel_score_history.dart';

class VowelScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  VowelScreen({required this.audioPlayer});

  @override
  _VowelScreenState createState() => _VowelScreenState();
}

class _VowelScreenState extends State<VowelScreen> with TickerProviderStateMixin {
  final List<String> vowels = ['/a/', '/e/', '/i/', '/o/', '/u/'];
  bool _isLoading = true;
  late FlutterTts flutterTts;
  late Map<String, AnimationController> _animationControllers;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final AudioPlayer _tapPlayer = AudioPlayer(); // Tap sound player

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ),
    );

    _animationControllers = {
      for (var vowel in vowels)
        vowel: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
          lowerBound: 0.9,
          upperBound: 1.1,
        )..addListener(() {
          setState(() {});
        }),
    };

    _initializeTTS();
    _startLoading();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _tapPlayer.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    flutterTts.stop();
    super.dispose();
  }

  void _initializeTTS() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.2);
    flutterTts.setSpeechRate(0.5);
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _slideController.forward();
  }

  Future<void> _playTapSound() async {
    await _tapPlayer.stop();
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));
  }

  void _handleTap(String letter) async {
    await _playTapSound(); // Play tap sound when tapping tile
    _animationControllers[letter]?.reverse();
    _navigateToDetails(letter);
  }

  void _navigateToDetails(String vowel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VowelScreenDetails(vowel: vowel)),
    );
  }

  Widget _buildLetterTile(String letter) {
    return GestureDetector(
      onTapDown: (_) => _animationControllers[letter]?.forward(),
      onTapUp: (_) => _handleTap(letter),
      onTapCancel: () => _animationControllers[letter]?.reverse(),
      child: Transform.scale(
        scale: _animationControllers[letter]?.value ?? 1.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.deepOrangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(5, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: GoogleFonts.poppins(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Check Pronunciation 🎶',
          style: GoogleFonts.poppins(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background1.jpg', fit: BoxFit.cover),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                      child: GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: vowels.length,
                        itemBuilder: (context, index) {
                          return _buildLetterTile(vowels[index]);
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _playTapSound(); // Play tap sound when pressing button
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VowelScoreHistory()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "View Score History",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

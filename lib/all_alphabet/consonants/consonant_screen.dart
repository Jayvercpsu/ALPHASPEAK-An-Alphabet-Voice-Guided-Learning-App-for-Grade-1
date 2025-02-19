import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consonant_detail_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConsonantScreen extends StatefulWidget {
  @override
  _ConsonantScreenState createState() => _ConsonantScreenState();
}

class _ConsonantScreenState extends State<ConsonantScreen> with TickerProviderStateMixin {
  final List<String> consonants = [
    'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M',
    'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'
  ];

  bool _isLoading = true;
  late FlutterTts flutterTts;
  late Map<String, AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controllers
    _animationControllers = {
      for (var letter in consonants)
        letter: AnimationController(
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
  }

  void _handleTap(String letter) async {
    if (flutterTts != null) { // Null safety check to avoid LateInitializationError
      await flutterTts.speak(letter);
    }
    _animationControllers[letter]?.reverse();
    _navigateToDetails(letter);
  }

  void _navigateToDetails(String letter) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConsonantDetailScreen(letter: letter)),
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
              style: GoogleFonts.berkshireSwash(
                fontSize: 50, // 🔥 Adjusted font size from 80 to 60
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
          'Consonants 🎶',
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: consonants.length,
                itemBuilder: (context, index) {
                  return _buildLetterTile(consonants[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'vowel_screen_details.dart';
import 'package:google_fonts/google_fonts.dart';

class VowelScreen extends StatefulWidget {
  @override
  _VowelScreenState createState() => _VowelScreenState();
}

class _VowelScreenState extends State<VowelScreen> with TickerProviderStateMixin {
  final List<String> vowels = ['/a/', '/e/', '/i/', '/o/', '/u/'];
  bool _isLoading = true;
  late FlutterTts flutterTts;
  late Map<String, AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller for each vowel
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
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
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
    await flutterTts.speak(letter);
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
                fontSize: 80,
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
          'Vowels 🎶',
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
        ],
      ),
    );
  }
}

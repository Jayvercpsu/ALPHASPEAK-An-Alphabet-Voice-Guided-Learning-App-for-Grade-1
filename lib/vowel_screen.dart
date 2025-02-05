import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import TTS package

class VowelScreen extends StatefulWidget {
  @override
  _VowelScreenState createState() => _VowelScreenState();
}

class _VowelScreenState extends State<VowelScreen> {
  final List<String> vowels = ['A', 'E', 'I', 'O', 'U'];
  bool _isLoading = true; // Show loading screen at start
  late FlutterTts flutterTts; // TTS instance

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _startLoading();
  }

  void _initializeTTS() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.2); // Slightly higher pitch (fun for kids)
    flutterTts.setSpeechRate(0.5); // Slow pronunciation
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate 1-second loading
    setState(() {
      _isLoading = false; // Hide loading screen
    });
  }

  // Function to speak the vowel
  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vowels 🎶',
          style: TextStyle(fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Loading Screen
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.pinkAccent),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black45,
                            blurRadius: 6,
                            offset: Offset(2, 2))
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            _buildLetterGrid(),
        ],
      ),
    );
  }

  // Grid view for vowels
  Widget _buildLetterGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns for better visibility
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: vowels.length,
        itemBuilder: (context, index) {
          return _letterTile(vowels[index]);
        },
      ),
    );
  }

// Tile for each vowel (Clickable + Cool Card Design with Click Effects)
  Widget _letterTile(String letter) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isClicked = false;

        return GestureDetector(
          onTapDown: (_) => setState(() => isClicked = true), // Start click effect
          onTapUp: (_) {
            setState(() => isClicked = false); // Reset click effect
            _speak(letter); // Speak the letter
          },
          onTapCancel: () => setState(() => isClicked = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isClicked ? 0.9 : 1.0), // Click shrink effect
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isClicked
                    ? [Colors.yellowAccent, Colors.orangeAccent] // Flash color on click
                    : [Colors.pinkAccent, Colors.deepOrangeAccent], // Default gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: isClicked ? 6 : 10, // Smaller shadow when clicked
                  offset: isClicked ? Offset(2, 2) : Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white60,
                  blurRadius: isClicked ? 4 : 6,
                  offset: isClicked ? Offset(-2, -2) : Offset(-4, -4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                splashColor: Colors.white24, // Ripple effect color
                highlightColor: Colors.transparent,
                onTap: () => _speak(letter), // Speak letter on tap
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 80, // BIGGER font for kids
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(3, 3)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
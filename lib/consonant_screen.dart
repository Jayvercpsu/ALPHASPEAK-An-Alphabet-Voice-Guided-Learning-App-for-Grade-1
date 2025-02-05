import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConsonantScreen extends StatefulWidget {
  @override
  _ConsonantScreenState createState() => _ConsonantScreenState();
}

class _ConsonantScreenState extends State<ConsonantScreen> {
  final List<String> consonants = [
    'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M',
    'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'
  ];

  bool _isLoading = true;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _startLoading();
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

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consonants 🎶',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
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

  Widget _buildLetterGrid() {
    return Padding(
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
          return _letterTile(consonants[index]);
        },
      ),
    );
  }

// Tile for each consonant (Clickable + Hover + Click Effects)
  Widget _letterTile(String letter) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isClicked = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isClicked = true),
            // Start click effect
            onTapUp: (_) {
              setState(() => isClicked = false); // End click effect
              _speak(letter); // Speak the consonant
            },
            onTapCancel: () => setState(() => isClicked = false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(isClicked ? 0.9 : (isHovered ? 1.1 : 1.0)),
              // Click effect
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isClicked
                      ? [
                    Colors.yellowAccent,
                    Colors.orangeAccent
                  ] // Click color change
                      : (isHovered
                      ? [
                    Colors.deepOrangeAccent,
                    Colors.pinkAccent
                  ] // Hover effect
                      : [Colors.pinkAccent, Colors.deepOrangeAccent]),
                  // Default colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: isHovered ? 14 : 10, // Enhanced 3D effect
                    offset: isHovered ? Offset(6, 6) : Offset(4, 4),
                  ),
                  BoxShadow(
                    color: Colors.white60,
                    blurRadius: isHovered ? 8 : 6,
                    offset: isHovered ? Offset(-6, -6) : Offset(-4, -4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  splashColor: Colors.white24,
                  // Ripple effect
                  highlightColor: Colors.transparent,
                  onTap: () => _speak(letter),
                  // Speak letter on tap
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(3, 3)),
                        ],
                      ),
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
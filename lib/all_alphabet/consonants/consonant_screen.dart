import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'consonant_detail_screen.dart'; // Import the new screen

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
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _letterTile(String letter) {
    return GestureDetector(
      onTap: () {
        _speak(letter); // Speak the consonant
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConsonantDetailScreen(letter: letter)), // Open detail screen
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(4, 4)),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

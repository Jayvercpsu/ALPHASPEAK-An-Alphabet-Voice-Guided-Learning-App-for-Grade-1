import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsonantDetailScreen extends StatefulWidget {
  final String letter;

  ConsonantDetailScreen({required this.letter});

  @override
  _ConsonantDetailScreenState createState() => _ConsonantDetailScreenState();
}

class _ConsonantDetailScreenState extends State<ConsonantDetailScreen> {
  late FlutterTts flutterTts;
  late List<String> exampleWords;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    exampleWords = _getExampleWords(widget.letter);
    _startLoading();
  }

  void _initializeTTS() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.2);
    flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  List<String> _getExampleWords(String letter) {
    Map<String, List<String>> wordExamples = {
      'B': ['Ball', 'Bubble', 'Banana', 'Book', 'Basket'],
      'C': ['Cat', 'Cake', 'Car', 'Candle', 'Chair'],
      'D': ['Dog', 'Duck', 'Dinosaur', 'Door', 'Doll'],
      'F': ['Fish', 'Fan', 'Fire', 'Fork', 'Feather'],
      'G': ['Goat', 'Giraffe', 'Glass', 'Gift', 'Garden'],
      'H': ['Hat', 'Horse', 'House', 'Hammer', 'Helicopter'],
      'J': ['Jam', 'Jelly', 'Jump', 'Jacket', 'Juice'],
      'K': ['Kite', 'King', 'Kangaroo', 'Keyboard', 'Kitchen'],
      'L': ['Lion', 'Lemon', 'Lamp', 'Leaf', 'Ladder'],
      'M': ['Moon', 'Milk', 'Monkey', 'Mirror', 'Mango'],
      'N': ['Nest', 'Nose', 'Nut', 'Notebook', 'Necklace'],
      'P': ['Pen', 'Pineapple', 'Pumpkin', 'Pillow', 'Panda'],
      'Q': ['Queen', 'Quilt', 'Quail', 'Quarter', 'Question'],
      'R': ['Rabbit', 'Rainbow', 'Rocket', 'Radio', 'Ring'],
      'S': ['Sun', 'Snake', 'Star', 'Scissors', 'Spider'],
      'T': ['Tree', 'Tiger', 'Train', 'Table', 'Tomato'],
      'V': ['Van', 'Violin', 'Vase', 'Vegetable', 'Vest'],
      'W': ['Water', 'Window', 'Whale', 'Watch', 'Wheel'],
      'X': ['Xylophone', 'X-ray', 'Xenon', 'Xerox', 'Xmas'],
      'Y': ['Yogurt', 'Yard', 'Yacht', 'Yellow', 'Yo-yo'],
      'Z': ['Zebra', 'Zoo', 'Zero', 'Zipper', 'Zigzag'],
    };

    return wordExamples[letter] ?? ['No examples found'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.letter} Sound',
          style: GoogleFonts.berkshireSwash(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
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
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: GoogleFonts.berkshireSwash(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            )

          // Main Content
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Letter Pronunciation
                Text(
                  '/${widget.letter.toLowerCase()}/',
                  style: GoogleFonts.berkshireSwash(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                    shadows: [
                      Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 2)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, size: 50, color: Colors.pinkAccent),
                  onPressed: () => _speak(widget.letter),
                ),
                SizedBox(height: 20),

                // Example Words
                Text(
                  "Example Words",
                  style: GoogleFonts.berkshireSwash(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 10),

                // Example Word List
                Column(
                  children: exampleWords.map((word) => _wordTile(word)).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _wordTile(String word) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1, offset: Offset(3, 3)),
          ],
        ),
        child: ListTile(
          leading: Icon(Icons.volume_up, color: Colors.pinkAccent),
          title: Text(
            word,
            style: GoogleFonts.berkshireSwash(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          onTap: () => _speak(word),
        ),
      ),
    );
  }
}

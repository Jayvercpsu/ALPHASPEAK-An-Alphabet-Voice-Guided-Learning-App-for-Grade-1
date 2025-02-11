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
    };

    return wordExamples[letter] ?? ['No examples found'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.letter} Consonant Words',
          style: GoogleFonts.berkshireSwash(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '/${widget.letter.toLowerCase()}/',
                  style: GoogleFonts.berkshireSwash(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, size: 50, color: Colors.pinkAccent),
                  onPressed: () => _speak(widget.letter),
                ),
                SizedBox(height: 20),
                Text(
                  "Example Words",
                  style: GoogleFonts.berkshireSwash(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 10),
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
          color: Colors.white,
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

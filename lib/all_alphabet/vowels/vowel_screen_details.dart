import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class VowelScreenDetails extends StatefulWidget {
  final String vowel;
  VowelScreenDetails({required this.vowel});

  @override
  _VowelScreenDetailsState createState() => _VowelScreenDetailsState();
}

class _VowelScreenDetailsState extends State<VowelScreenDetails> {
  late FlutterTts flutterTts;

  final Map<String, List<String>> vowelWords = {
    '/a/': ['cat', 'bat', 'sat', 'mat', 'rat', 'hat'],
    '/e/': ['pen', 'ten', 'hen', 'net', 'pet', 'vet'],
    '/i/': ['pin', 'win', 'fin', 'bin', 'tin', 'sin'],
    '/o/': ['dog', 'log', 'fog', 'jog', 'hog', 'bog'],
    '/u/': ['mud', 'hug', 'tub', 'sub', 'rub', 'cup'],
  };

  @override
  void initState() {
    super.initState();
    _initializeTTS();
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

  @override
  Widget build(BuildContext context) {
    List<String> words = vowelWords[widget.vowel] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.vowel} Words',
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Words with ${widget.vowel}',
                  style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
                ),
                SizedBox(height: 20),
                _buildWordList(words),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(List<String> words) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: words.map((word) => _wordTile(word)).toList(),
    );
  }

  Widget _wordTile(String word) {
    return GestureDetector(
      onTap: () => _speak(word),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: GoogleFonts.berkshireSwash(fontSize: 24, color: Colors.black87),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
              onPressed: () => _speak(word),
            ),
          ],
        ),
      ),
    );
  }
}

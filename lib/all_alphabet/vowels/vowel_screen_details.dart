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

  bool _isLoading = true;

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
    List<String> words = vowelWords[widget.vowel] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.vowel} Vowel Words',
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
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display Vowel Pronunciation
                  Text(
                    widget.vowel,
                    style: GoogleFonts.poppins(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up, size: 50, color: Colors.pinkAccent),
                    onPressed: () => _speak(widget.vowel),
                  ),
                  SizedBox(height: 20),

                  // Section Title with Background Color
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent, // Background color added
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(3, 3)),
                      ],
                    ),
                    child: Text(
                      "Example Words",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for contrast
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Example Word List
                  Column(
                    children: words.map((word) => _wordTile(word)).toList(),
                  ),
                ],
              ),
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
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          onTap: () => _speak(word),
        ),
      ),
    );
  }
}

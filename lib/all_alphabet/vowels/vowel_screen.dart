import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'vowel_screen_details.dart';
import 'package:google_fonts/google_fonts.dart';

class VowelScreen extends StatefulWidget {
  @override
  _VowelScreenState createState() => _VowelScreenState();
}

class _VowelScreenState extends State<VowelScreen> {
  final List<String> vowels = ['/a/', '/e/', '/i/', '/o/', '/u/'];
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

  void _navigateToDetails(String vowel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VowelScreenDetails(vowel: vowel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vowels 🎶',
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
          crossAxisCount: 2,
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

  Widget _letterTile(String letter) {
    return GestureDetector(
      onTap: () => _navigateToDetails(letter),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3))],
        ),
        child: Center(
          child: Text(
            letter,
            style: GoogleFonts.berkshireSwash(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

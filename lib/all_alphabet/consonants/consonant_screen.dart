import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consonant_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToDetails(String letter) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConsonantDetailScreen(letter: letter)),
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
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
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
            style: GoogleFonts.berkshireSwash(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

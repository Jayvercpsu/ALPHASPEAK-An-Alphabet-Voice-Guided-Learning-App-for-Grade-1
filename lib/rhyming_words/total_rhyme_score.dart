import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalRhymeScoreScreen extends StatefulWidget {
  @override
  _TotalRhymeScoreScreenState createState() => _TotalRhymeScoreScreenState();
}

class _TotalRhymeScoreScreenState extends State<TotalRhymeScoreScreen> {
  int _easyScore = 0;
  int _mediumScore = 0;
  int _hardScore = 0;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _easyScore = prefs.getInt('easy_score') ?? 0;
      _mediumScore = prefs.getInt('medium_score') ?? 0;
      _hardScore = prefs.getInt('hard_score') ?? 0;
      _totalScore = _easyScore + _mediumScore + _hardScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total Score 🏆',
          style: GoogleFonts.berkshireSwash(fontSize: 26, color: Colors.white),
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
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Score',
                    style: GoogleFonts.berkshireSwash(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Easy: $_easyScore',
                    style: GoogleFonts.berkshireSwash(fontSize: 22, color: Colors.green),
                  ),
                  Text(
                    'Medium: $_mediumScore',
                    style: GoogleFonts.berkshireSwash(fontSize: 22, color: Colors.orange),
                  ),
                  Text(
                    'Hard: $_hardScore',
                    style: GoogleFonts.berkshireSwash(fontSize: 22, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total: $_totalScore',
                    style: GoogleFonts.berkshireSwash(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.berkshireSwash(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BenTedScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const BenTedScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _BenTedScreenState createState() => _BenTedScreenState();
}

class _BenTedScreenState extends State<BenTedScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startLoading();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startNarration();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _startNarration() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(
      "Ted has a red tent. He is in the tent. Ben is in the tent too. 10 hens ran into the tent. The tent fell on Ben, Ted, and the ten hens. Ben and Ted yell for help.",
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stories 📚',
          style: GoogleFonts.berkshireSwash(fontSize: 28, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          else
            SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ted and Ben's Adventure",
                      style: GoogleFonts.berkshireSwash(
                        fontSize: screenHeight * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/stories/ben_ted.jpg',
                            width: screenWidth * 0.8,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Ted has a red tent.\nHe is in the tent.\nBen is in the tent too.\n10 hens ran into the tent.\nThe tent fell on Ben, Ted, and the ten hens.\nBen and Ted yell for help.",
                            style: GoogleFonts.poppins(
                              fontSize: screenHeight * 0.025,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildQuestions(screenHeight, screenWidth),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestions(double screenHeight, double screenWidth) {
    List<String> questions = [
      "1. Who has a red tent?",
      "2. How many hens ran into the tent?",
      "3. What did Ben and Ted do?",
      "4. If you were Ben and Ted, would you have done the same?",
      "5. Who are our community helpers who can help us in times of need? How do they help?"
    ];

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2, offset: Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions.map((question) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              question,
              style: GoogleFonts.poppins(fontSize: screenHeight * 0.025, color: Colors.blueAccent),
            ),
          );
        }).toList(),
      ),
    );
  }
}

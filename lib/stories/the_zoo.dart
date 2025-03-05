import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TheZooScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const TheZooScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _TheZooScreenState createState() => _TheZooScreenState();
}

class _TheZooScreenState extends State<TheZooScreen> with SingleTickerProviderStateMixin {
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _startNarration() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(
      "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
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
                      "The Zoo",
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
                            'assets/stories/the_zoo.jpg',
                            width: screenWidth * 0.8,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Have you been to the zoo?\nWhat do you see in the zoo?\nIn the zoo, we see wild animals.\nWe see a zebra, a tiger, a lion, and a crocodile.\nWe also see other animals like eagles, monkeys, large fishes, and ostrich.",
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
      "1. Have you been to the zoo?",
      "2. What do you see in a zoo?",
      "3. Give examples of wild animals that you can see there?",
      "4. Do you think animals like to live in the zoo?",
      "5. Who keeps the animals in the zoo well?",
      "6. How can you help or what can you do to the animals in the zoo to survive for a long time?"
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

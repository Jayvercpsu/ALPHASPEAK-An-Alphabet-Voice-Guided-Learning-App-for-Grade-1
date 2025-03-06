import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ben_ted.dart';
import 'the_zoo.dart';

class StoriesScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const StoriesScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _StoriesScreenState createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

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
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "Choose a Story",
                      style: GoogleFonts.berkshireSwash(
                        fontSize: screenHeight * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildStoryCard(
                      imagePath: 'assets/stories/ben_ted.jpg',
                      title: "Ben and Ted's Adventure",
                      screen: BenTedScreen(audioPlayer: widget.audioPlayer),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildStoryCard(
                      imagePath: 'assets/stories/the_zoo.jpg',
                      title: "The Zoo",
                      screen: TheZooScreen(audioPlayer: widget.audioPlayer),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryCard({
    required String imagePath,
    required String title,
    required Widget screen,
    required double screenHeight,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        padding: EdgeInsets.all(screenHeight * 0.02),
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
              imagePath,
              width: screenWidth * 0.8,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.berkshireSwash(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

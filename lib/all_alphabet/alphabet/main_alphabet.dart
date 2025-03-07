import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../vowels/vowel_screen.dart';
import '../consonants/consonant_screen.dart';
import 'alphabet_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class MainAlphabet extends StatefulWidget {
  final AudioPlayer audioPlayer;

  MainAlphabet({required this.audioPlayer});

  @override
  _MainAlphabetState createState() => _MainAlphabetState();
}

class _MainAlphabetState extends State<MainAlphabet> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _initializeAnimation(); // Initialize animation first
    super.initState();
    _startLoading();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0), // Start from bottom
      end: Offset.zero,        // End at center
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
    _animationController.forward(); // Start the animation after loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alphabet Categories',
          style: GoogleFonts.poppins(fontSize: 26, color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent,
              ),
            )
                : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: _interactiveCategoryButton(
                        context,
                        'All Letters',
                        Icons.menu_book_rounded,
                        Colors.pinkAccent,
                        AlphabetScreen(audioPlayer: widget.audioPlayer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactiveCategoryButton(
      BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

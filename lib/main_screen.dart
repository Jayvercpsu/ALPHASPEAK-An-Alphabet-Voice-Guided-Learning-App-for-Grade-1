import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Single instance for audio
  final AudioPlayer _tapPlayer = AudioPlayer(); // For tap sound

  late AnimationController _welcomeController;
  late AnimationController _buttonController;
  late AnimationController _gifController;

  late Animation<Offset> _welcomeOffsetAnimation;
  late Animation<Offset> _buttonOffsetAnimation;

  double _gifOpacity = 0;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();

    // Animation controllers and animations
    _welcomeController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _gifController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _welcomeOffsetAnimation = Tween<Offset>(
      begin: Offset(-1.5, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOut,
    ));

    _buttonOffsetAnimation = Tween<Offset>(
      begin: Offset(0, 1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Start GIF fade-in
    setState(() => _gifOpacity = 1);
    _gifController.forward();

    // Welcome text slides in
    _welcomeController.forward();

    // Slide-in button
    await Future.delayed(Duration(milliseconds: 500));
    _buttonController.forward();
  }

  Future<void> _playBackgroundMusic() async {
    // Play background music in a loop
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop mode
    await _audioPlayer.play(AssetSource('bg_music.mp3'), volume: 0.5);
  }

  Future<void> _playTapSound() async {
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tapPlayer.dispose();
    _welcomeController.dispose();
    _buttonController.dispose();
    _gifController.dispose();
    super.dispose();
  }

  Future<void> _onPlayButtonPressed(BuildContext context) async {
    // Play tap sound
    await _playTapSound();

    // Show loading for 1 second
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 1));

    // Close the loading dialog
    Navigator.pop(context);

    // Navigate to HomeScreen with the _audioPlayer instance
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(audioPlayer: _audioPlayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display GIF with fade-in
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: _gifOpacity,
              child: Image.asset(
                'assets/abc.gif',
                width: 250,
                height: 250,
              ),
            ),
            SizedBox(height: 20),

            // Welcome Text with slide-in animation
            SlideTransition(
              position: _welcomeOffsetAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  // Increased opacity for better contrast
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      // Darker shadow for a floating effect
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      for (int i = 0; i < "Welcome to AlphaSpeak!".length; i++)
                        TextSpan(
                          text: "Welcome to AlphaSpeak!"[i],
                          style: GoogleFonts.pacifico(
                            fontSize: 30,
                            // Slightly larger for better visibility
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.indigo,
                              Colors.purple
                            ][i % 7],
                            // Cycle through rainbow colors
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                // Stronger shadow for depth
                                blurRadius: 8,
                                offset: Offset(3, 3),
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                // Soft glowing effect
                                blurRadius: 12,
                                offset: Offset(-2, -2),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Play Button with slide-in animation
            SlideTransition(
              position: _buttonOffsetAnimation,
              child: ElevatedButton(
                onPressed: () => _onPlayButtonPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  elevation: 10,
                ),
                child: Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

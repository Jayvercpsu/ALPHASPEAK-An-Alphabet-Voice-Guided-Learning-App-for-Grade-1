import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _tapPlayer = AudioPlayer();

  late AnimationController _logoBounceController;
  late AnimationController _textPulseController;
  late AnimationController _buttonController;

  late Animation<double> _logoBounceAnimation;
  late Animation<double> _textPulseAnimation;
  late Animation<Offset> _buttonOffsetAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();

    // ✅ Initialize animation controllers before using them
    _logoBounceController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _logoBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoBounceController,
      curve: Curves.easeInOut,
    ));

    _textPulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _textPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _textPulseController,
      curve: Curves.easeInOut,
    ));

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _buttonOffsetAnimation = Tween<Offset>(
      begin: Offset(0, 1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }


  Future<void> _startAnimations() async {
    _buttonController.forward();
  }

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('bg_music.mp3'), volume: 0.5);
  }

  Future<void> _playTapSound() async {
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tapPlayer.dispose();
    _logoBounceController.dispose();
    _textPulseController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _onPlayButtonPressed(BuildContext context) async {
    await _playTapSound();

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
    Navigator.pop(context);

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
            // Animated Logo
            ScaleTransition(
              scale: _logoBounceAnimation,
              child: Image.asset(
                'assets/alphabet.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),

            // "Alphabet Guided Learning App" Text with Pulse Animation
            ScaleTransition(
              scale: _textPulseAnimation,
              child: Text(
                "Alphabet Guided Learning App",
                textAlign: TextAlign.center,
                style: GoogleFonts.berkshireSwash(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                  shadows: [
                    Shadow(
                      blurRadius: 6.0,
                      color: Colors.white,
                      offset: Offset(2, 2),
                    ),
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.white.withOpacity(0.5),
                      offset: Offset(-1, -1),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Welcome Text with Soft Glow
            Text(
              "Welcome to AlphaSpeak!",
              textAlign: TextAlign.center,
              style: GoogleFonts.berkshireSwash(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black54,
                    offset: Offset(3, 3),
                  ),
                  Shadow(
                    blurRadius: 12.0,
                    color: Colors.blueAccent.withOpacity(0.5),
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Play Button with Ripple Effect
            SlideTransition(
              position: _buttonOffsetAnimation,
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut))),
                  onTapUp: (_) => setState(() => _buttonScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut))),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.6),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _onPlayButtonPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                        elevation: 12,
                      ),
                      child: Text(
                        'Play',
                        style: GoogleFonts.berkshireSwash(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
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

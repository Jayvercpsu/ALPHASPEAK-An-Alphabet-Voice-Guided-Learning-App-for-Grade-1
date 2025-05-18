import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'user_info_screen.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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
  late AnimationController _bgBlurController;

  late Animation<double> _logoBounceAnimation;
  late Animation<double> _textPulseAnimation;
  late Animation<Offset> _buttonOffsetAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _bgBlurAnimation;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();

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

    _bgBlurController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _bgBlurAnimation = Tween<double>(
      begin: 3,
      end: 6,
    ).animate(CurvedAnimation(
      parent: _bgBlurController,
      curve: Curves.easeInOut,
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
    _bgBlurController.dispose();
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
        builder: (context) => UserInfoScreen(audioPlayer: _audioPlayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background with Blur Effect
          AnimatedBuilder(
            animation: _bgBlurAnimation,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/background1.jpg',
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _bgBlurAnimation.value,
                      sigmaY: _bgBlurAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ],
              );
            },
          ),

          // Foreground Content
          Column(
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

              // Animated App Title
              ScaleTransition(
                scale: _textPulseAnimation,
                child: Text(
                  "Alphabet Guided Learning App",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.white,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Welcome Text with Glowing Effect
              Text(
                "Welcome to AlphaSpeak!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      blurRadius: 12.0,
                      color: Colors.blueAccent.withOpacity(0.7),
                      offset: Offset(-2, -2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Play Button with Animated Glow
              SlideTransition(
                position: _buttonOffsetAnimation,
                child: ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: GestureDetector(
                    onTap: () => _onPlayButtonPressed(context),
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
                            color: Colors.orangeAccent.withOpacity(0.9),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                      child: Text(
                        'Play',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

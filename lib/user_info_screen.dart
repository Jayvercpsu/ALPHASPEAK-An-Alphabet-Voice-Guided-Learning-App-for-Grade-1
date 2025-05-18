import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

class UserInfoScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const UserInfoScreen({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _sectionController = TextEditingController();
  bool _isCheckingUser = true;
  bool _hasExistingUser = false;

  late AudioPlayer _tapPlayer;
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideInAnimation;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
    _tapPlayer = AudioPlayer();

    _fadeInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    ));

    _slideInAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.decelerate,
    ));
  }

  Future<void> _checkExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final section = prefs.getString('section');

    if (username != null && username.isNotEmpty &&
        section != null && section.isNotEmpty) {
      setState(() {
        _hasExistingUser = true;
        _isCheckingUser = false;
      });
      // Navigate directly to home screen if user exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(audioPlayer: widget.audioPlayer),
          ),
        );
      });
    } else {
      setState(() {
        _isCheckingUser = false;
      });
      _fadeInController.forward();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _sectionController.dispose();
    _fadeInController.dispose();
    _tapPlayer.dispose();
    super.dispose();
  }

  void _onDonePressed() async {
    await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'), volume: 1.0);

    final username = _usernameController.text.trim();
    final section = _sectionController.text.trim();

    if (username.isNotEmpty && section.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('section', section);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(audioPlayer: widget.audioPlayer),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both Username and Section')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUser) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasExistingUser) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/background1.jpg',
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ],
          ),

          // Foreground Content
          Center(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideInAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enter Your Info",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _sectionController,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _onDonePressed,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          child: Text(
                            "Done",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
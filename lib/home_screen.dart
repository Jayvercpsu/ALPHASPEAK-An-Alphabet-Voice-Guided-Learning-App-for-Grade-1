import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all_alphabet/alphabet/main_alphabet.dart';
import 'rhyming_words/main_rhyming_words.dart';
import 'check_pronunciation/vowels/vowel_screen.dart';
import 'word_puzzle/word_puzzle.dart';
import 'stories/stories_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const HomeScreen({Key? key, required this.audioPlayer}) : super(key: key);

  final double imageSize = 150;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _tapPlayer = AudioPlayer();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _resumeBackgroundMusic();
  }

  Future<void> _resumeBackgroundMusic() async {
    if (!_isMuted) {
      await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
      await widget.audioPlayer.resume();
    }
  }

  Future<void> _stopAllSounds() async {
    await widget.audioPlayer.pause();
    await _tapPlayer.stop();
  }

  Future<void> _playTapSound() async {
    if (!_isMuted) {
      await _tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'), volume: 1.0);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _stopAllSounds();
      } else {
        _resumeBackgroundMusic();
      }
    });
  }

  @override
  void dispose() {
    _tapPlayer.dispose();
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = 150;
    final double buttonHeight = 150;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Image.asset(
                      _isMuted ? 'assets/unmute.png' : 'assets/mute.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder(
                          duration: Duration(seconds: 2),
                          tween: Tween<double>(begin: 0, end: 10),
                          curve: Curves.easeInOut,
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, sin(value) * 5),
                              child: Image.asset(
                                'assets/alphabet.png',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "AlphaSpeak: Alphabet Learning App",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.berkshireSwash(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 5,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFeatureRow(
                                context,
                                [
                                  _FeatureItem(
                                    text: "Learn Alphabet",
                                    imagePath: 'assets/home-screen/abc.png',
                                    screen: MainAlphabet(audioPlayer: widget.audioPlayer),
                                  ),
                                  _FeatureItem(
                                    text: "Rhyming Words",
                                    imagePath: 'assets/home-screen/matching.png',
                                    screen: RhymingWordsScreen(audioPlayer: widget.audioPlayer),
                                  ),
                                ],
                                buttonWidth,
                                buttonHeight,
                                slideFromLeft: true,
                                delayMilliseconds: 100,
                              ),
                              SizedBox(height: 20),
                              _buildFeatureRow(
                                context,
                                [
                                  _FeatureItem(
                                    text: "Check Pronunciation",
                                    imagePath: 'assets/home-screen/voice.png',
                                    screen: VowelScreen(audioPlayer: widget.audioPlayer),
                                  ),
                                  _FeatureItem(
                                    text: "Word Puzzle",
                                    imagePath: 'assets/home-screen/puzzle.png',
                                    screen: WordPuzzleScreen(audioPlayer: widget.audioPlayer),
                                  ),
                                ],
                                buttonWidth,
                                buttonHeight,
                                slideFromLeft: false,
                                delayMilliseconds: 200,
                              ),
                              SizedBox(height: 40),
                              _buildFeatureRow(
                                context,
                                [
                                  _FeatureItem(
                                    text: "Stories",
                                    imagePath: 'assets/home-screen/stories.png',
                                    screen: StoriesScreen(audioPlayer: widget.audioPlayer),
                                  ),
                                ],
                                buttonWidth,
                                buttonHeight,
                                slideFromLeft: false,
                                delayMilliseconds: 200,
                              ),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
      BuildContext context, List<_FeatureItem> features, double width, double height,
      {required bool slideFromLeft, required int delayMilliseconds}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Flexible(
          child: _FeatureButton(
            text: feature.text,
            imagePath: feature.imagePath,
            width: width,
            height: height,
            screen: feature.screen,
            slideFromLeft: slideFromLeft,
            delayMilliseconds: delayMilliseconds,
            playTapSound: _playTapSound,
            stopBackgroundMusic: _stopAllSounds,
            resumeBackgroundMusic: _resumeBackgroundMusic,
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureItem {
  final String text;
  final String imagePath;
  final Widget screen;

  _FeatureItem({required this.text, required this.imagePath, required this.screen});
}

class _FeatureButton extends StatefulWidget {
  final String text, imagePath;
  final double width, height;
  final Widget screen;
  final bool slideFromLeft;
  final int delayMilliseconds;
  final Future<void> Function() playTapSound, stopBackgroundMusic, resumeBackgroundMusic;

  const _FeatureButton({
    required this.text,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.screen,
    required this.slideFromLeft,
    required this.delayMilliseconds,
    required this.playTapSound,
    required this.stopBackgroundMusic,
    required this.resumeBackgroundMusic,
  });

  @override
  State<_FeatureButton> createState() => _FeatureButtonState();
}

class _FeatureButtonState extends State<_FeatureButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 600),
      opacity: _isVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 600),
        offset: _isVisible ? Offset.zero : Offset(widget.slideFromLeft ? -1 : 1, 0),
        child: GestureDetector(
          onTap: () async {
            await widget.playTapSound(); // Play tap sound
            widget.stopBackgroundMusic(); // Stop background music before navigation
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => widget.screen),
            );
            widget.resumeBackgroundMusic(); // Resume background music after navigation
          },
          child: Column(
            children: [
              Image.asset(widget.imagePath, width: widget.width, height: widget.height),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.text,
                  style: GoogleFonts.berkshireSwash(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

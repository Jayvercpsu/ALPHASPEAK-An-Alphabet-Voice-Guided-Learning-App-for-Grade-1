import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_alphabet/alphabet/alphabet_screen.dart';
import 'rhyming_words/main_rhyming_words.dart';
import 'check_pronunciation/vowels/vowel_screen.dart';
import 'word_puzzle/word_puzzle.dart';
import 'stories/stories_screen.dart';
import 'progress_tracker.dart';

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
  String _username = '';
  String _section = '';
  Map<String, dynamic> _progressData = {};
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    _resumeBackgroundMusic();
    _loadUserInfo();
    _loadProgressData();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _section = prefs.getString('section') ?? '';
    });
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('progress_data');

    // Load all scores from SharedPreferences
    final easyRhymeScore = prefs.getInt('easy_score') ?? 0;
    final mediumRhymeScore = prefs.getInt('medium_score') ?? 0;
    final hardRhymeScore = prefs.getInt('hard_score') ?? 0;

    final easyWordScore = prefs.getInt('easy_word_score') ?? 0;
    final mediumWordScore = prefs.getInt('medium_word_score') ?? 0;
    final hardWordScore = prefs.getInt('hard_word_score') ?? 0;

    // Get current date for last played
    final currentDate = DateTime.now().toString();

    if (progressJson != null) {
      setState(() {
        _progressData = json.decode(progressJson);

        // Update scores and dates only if they've increased
        if (easyRhymeScore > (_progressData['Rhyming Words']['Easy']['score'] ?? 0)) {
          _progressData['Rhyming Words']['Easy']['score'] = easyRhymeScore;
          _progressData['Rhyming Words']['Easy']['date'] = currentDate;
        }
        if (mediumRhymeScore > (_progressData['Rhyming Words']['Medium']['score'] ?? 0)) {
          _progressData['Rhyming Words']['Medium']['score'] = mediumRhymeScore;
          _progressData['Rhyming Words']['Medium']['date'] = currentDate;
        }
        if (hardRhymeScore > (_progressData['Rhyming Words']['Hard']['score'] ?? 0)) {
          _progressData['Rhyming Words']['Hard']['score'] = hardRhymeScore;
          _progressData['Rhyming Words']['Hard']['date'] = currentDate;
        }

        if (easyWordScore > (_progressData['Word Puzzle']['Easy']['score'] ?? 0)) {
          _progressData['Word Puzzle']['Easy']['score'] = easyWordScore;
          _progressData['Word Puzzle']['Easy']['date'] = currentDate;
        }
        if (mediumWordScore > (_progressData['Word Puzzle']['Medium']['score'] ?? 0)) {
          _progressData['Word Puzzle']['Medium']['score'] = mediumWordScore;
          _progressData['Word Puzzle']['Medium']['date'] = currentDate;
        }
        if (hardWordScore > (_progressData['Word Puzzle']['Hard']['score'] ?? 0)) {
          _progressData['Word Puzzle']['Hard']['score'] = hardWordScore;
          _progressData['Word Puzzle']['Hard']['date'] = currentDate;
        }

        // Update all statuses
        _updateAllStatuses();
      });
    } else {
      setState(() {
        _progressData = {
          'Rhyming Words': {
            'date': currentDate,
            'Easy': _createProgressEntry(easyRhymeScore, 15),
            'Medium': _createProgressEntry(mediumRhymeScore, 15),
            'Hard': _createProgressEntry(hardRhymeScore, 15),
          },
          'Word Puzzle': {
            'date': currentDate,
            'Easy': _createProgressEntry(easyWordScore, 15),
            'Medium': _createProgressEntry(mediumWordScore, 15),
            'Hard': _createProgressEntry(hardWordScore, 15),
          },
          'Stories': {
            'date': currentDate,
            'Easy': {'score': 0, 'total': 15, 'status': 'Failed'},
            'Medium': {'score': 6, 'total': 15, 'status': 'Good'},
            'Hard': {'score': 9, 'total': 15, 'status': 'Very Good'},
          },
        };
        _saveProgressData();
      });
    }
  }

  Map<String, dynamic> _createProgressEntry(int score, int total) {
    return {
      'score': score,
      'total': total,
      'status': _calculateStatus(score, total),
    };
  }

  void _updateAllStatuses() {
    // Update status for all activities and difficulties
    _progressData['Rhyming Words']['Easy']['status'] =
        _calculateStatus(_progressData['Rhyming Words']['Easy']['score'], 15);
    _progressData['Rhyming Words']['Medium']['status'] =
        _calculateStatus(_progressData['Rhyming Words']['Medium']['score'], 15);
    _progressData['Rhyming Words']['Hard']['status'] =
        _calculateStatus(_progressData['Rhyming Words']['Hard']['score'], 15);

    _progressData['Word Puzzle']['Easy']['status'] =
        _calculateStatus(_progressData['Word Puzzle']['Easy']['score'], 15);
    _progressData['Word Puzzle']['Medium']['status'] =
        _calculateStatus(_progressData['Word Puzzle']['Medium']['score'], 15);
    _progressData['Word Puzzle']['Hard']['status'] =
        _calculateStatus(_progressData['Word Puzzle']['Hard']['score'], 15);

    // Stories status remains static as per your initial implementation
  }

  String _calculateStatus(int score, int total) {
    double percentage = score / total;
    if (percentage < 0.5) return 'Failed';
    if (percentage < 0.75) return 'Good';
    return 'Very Good';
  }

  Future<void> _saveProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progress_data', json.encode(_progressData));
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

  void _toggleProgressView() {
    setState(() {
      _showProgress = !_showProgress;
    });
  }

  Future<void> _updateProfile(String username, String section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('section', section);
    setState(() {
      _username = username;
      _section = section;
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.person, size: 32, color: Colors.white),
                        onPressed: _toggleProgressView,
                      ),
                      Row(
                        children: [
                          if (_username.isNotEmpty || _section.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '$_username - $_section',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: Image.asset(
                              _isMuted ? 'assets/unmute.png' : 'assets/mute.png',
                              width: 32,
                              height: 32,
                            ),
                            onPressed: _toggleMute,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_showProgress)
                  Expanded(
                    child: ProgressTracker(
                      progressData: _progressData,
                      username: _username,
                      section: _section,
                      onBackToHome: _toggleProgressView,
                      onProfileUpdate: _updateProfile,
                    ),
                  )
                else
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
                                style: GoogleFonts.poppins(
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
                                      screen: AlphabetScreen(audioPlayer: widget.audioPlayer),
                                    ),
                                    _FeatureItem(
                                      text: "Rhyming Words",
                                      imagePath: 'assets/home-screen/rhyming.png',
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
            await widget.playTapSound();
            widget.stopBackgroundMusic();
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => widget.screen),
            );
            widget.resumeBackgroundMusic();
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
                  style: GoogleFonts.poppins(
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
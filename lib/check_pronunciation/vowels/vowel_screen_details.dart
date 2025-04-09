            import 'package:flutter/material.dart';
            import 'package:flutter_tts/flutter_tts.dart';
            import 'package:google_fonts/google_fonts.dart';
            import 'package:speech_to_text/speech_to_text.dart' as stt;
            import 'package:confetti/confetti.dart';
            import 'package:shared_preferences/shared_preferences.dart';
            import 'dart:async';
            import 'package:audioplayers/audioplayers.dart';
            import 'package:avatar_glow/avatar_glow.dart';

            class VowelScreenDetails extends StatefulWidget {
              final String vowel;

              VowelScreenDetails({required this.vowel});

              @override
              _VowelScreenDetailsState createState() => _VowelScreenDetailsState();
            }

            class _VowelScreenDetailsState extends State<VowelScreenDetails> {
              late FlutterTts flutterTts;
              late stt.SpeechToText _speechToText;
              bool _speechEnabled = false;
              String _spokenWord = '';
              Map<String, int> _countdowns = {};
              String _currentWord = '';
              bool _showMic = false;
              late ConfettiController _confettiController;
              int _totalScore = 0;
              int _countdown = 0;
              Timer? _countdownTimer;
              bool _hasShownIncorrectMessage = false;
              bool _isProcessingResult = false;

              final Map<String, List<String>> vowelWords = {
                '/a/': [
                  'cat',
                  'bat',
                  'sat',
                  'mat',
                  'rat',
                  'hat',
                  'pat',
                  'chat',
                  'flat',
                  'that',
                  'tap',
                  'lap',
                  'snap',
                  'trap',
                  'map',
                  'cap',
                  'clap',
                  'nap',
                  'gap',
                  'sap',
                  'rap',
                  'slap',
                  'crap',
                  'wrap',
                  'scrap',
                  'flap',
                  'snap',
                  'strap',
                  'crack',
                  'track'
                ],
                '/e/': [
                  'pen',
                  'ten',
                  'hen',
                  'net',
                  'pet',
                  'vet',
                  'set',
                  'bet',
                  'let',
                  'met',
                  'get',
                  'wet',
                  'jet',
                  'yet',
                  'debt',
                  'fret',
                  'sweat',
                  'regret',
                  'upset',
                  'reset',
                  'forget',
                  'budget',
                  'velvet',
                  'helmet',
                  'magnet',
                  'gadget',
                  'racket',
                  'jacket',
                  'packet',
                  'blanket'
                ],
                '/i/': [
                  'pin',
                  'win',
                  'fin',
                  'bin',
                  'tin',
                  'sin',
                  'skin',
                  'grin',
                  'chin',
                  'spin',
                  'thin',
                  'begin',
                  'within',
                  'ruin',
                  'cousin',
                  'villain',
                  'pudding',
                  'chicken',
                  'hidden',
                  'kitten',
                  'mittens',
                  'ridden',
                  'sitting',
                  'bitten',
                  'written',
                  'quitting',
                  'spitting',
                  'splitting',
                  'hitting',
                  'fitting'
                ],
                '/o/': [
                  'dog',
                  'log',
                  'fog',
                  'jog',
                  'hog',
                  'bog',
                  'frog',
                  'clog',
                  'smog',
                  'slog',
                  'job',
                  'mob',
                  'sob',
                  'cob',
                  'rob',
                  'knob',
                  'blob',
                  'slob',
                  'fob',
                  'bob',
                  'nod',
                  'rod',
                  'cod',
                  'mod',
                  'prod',
                  'squad',
                  'broad',
                  'plod',
                  'trodden',
                  'shod'
                ],
                '/u/': [
                  'mud',
                  'hug',
                  'tub',
                  'sub',
                  'rub',
                  'cup',
                  'pup',
                  'up',
                  'sum',
                  'gum',
                  'hum',
                  'bump',
                  'jump',
                  'pump',
                  'plump',
                  'dump',
                  'stump',
                  'grump',
                  'thump',
                  'rump',
                  'chump',
                  'lump',
                  'slump',
                  'crump',
                  'rumpus',
                  'mumps',
                  'trump',
                  'hump',
                  'stump',
                  'dumb'
                ],
              };

              final AudioPlayer _audioPlayer = AudioPlayer();

              @override
              void initState() {
                super.initState();
                _confettiController = ConfettiController(duration: Duration(seconds: 2));
                _initializeTTS();
                _initializeSpeech();
                _initializeCountdowns();
                _loadScore();
              }

              @override
              void dispose() {
                _confettiController.dispose();
                flutterTts.stop();
                _countdownTimer?.cancel();
                super.dispose();
              }

              void _initializeTTS() {
                flutterTts = FlutterTts();
                flutterTts.setLanguage("en-US");
                flutterTts.setPitch(1.2);
                flutterTts.setSpeechRate(0.5);
                flutterTts.awaitSpeakCompletion(true);
              }

              Future<void> _speak(String text) async {
                await flutterTts.speak(text);
                await flutterTts.awaitSpeakCompletion(true);
              }

              void _initializeSpeech() async {
                _speechToText = stt.SpeechToText();
                _speechEnabled = await _speechToText.initialize();
              }

              void _initializeCountdowns() {
                List<String> words = vowelWords[widget.vowel] ?? [];
                for (var word in words) {
                  _countdowns[word] = 0;
                }
              }

              Future<void> _loadScore() async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  _totalScore = prefs.getInt('score_${widget.vowel}') ?? 0;
                });
              }

              Future<void> _updateScore() async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  _totalScore += 1;
                });
                await prefs.setInt('score_${widget.vowel}', _totalScore);
              }

              void _startCountdown(String word) {
                _countdownTimer?.cancel();
                _speechToText.stop();
                flutterTts.stop();

                _isProcessingResult = false; // Reset flag

                setState(() {
                  _currentWord = word;
                  _spokenWord = '';
                  _showMic = true;
                  _countdown = 5;
                  _hasShownIncorrectMessage = false;
                });

                _speak("Say the word: $word").then((_) {
                  if (!mounted) return;

                  setState(() {
                    _showMic = true;
                  });

                  _startListening(word);

                  _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                    if (!mounted) {
                      timer.cancel();
                      return;
                    }

                    if (_countdown > 0) {
                      setState(() {
                        _countdown--;
                      });
                    } else {
                      timer.cancel();
                    }
                  });
                });
              }




            // ✅ Add a variable to track the Timer instance



              void _startListening(String word) async {
                if (!mounted) return;

                // Reset processing flag when starting new listening session
                _isProcessingResult = false;

                setState(() {
                  _showMic = true;
                  _spokenWord = 'Listening...';
                });

                if (!_speechToText.isAvailable) {
                  await _speechToText.initialize();
                }

                await _speechToText.stop(); // Ensure previous session is stopped
                await Future.delayed(Duration(milliseconds: 300)); // Stability delay

                _speechToText.listen(
                  onResult: (result) {
                    if (!mounted || _isProcessingResult) return;

                    String recognized = result.recognizedWords.toLowerCase();
                    if (recognized.isNotEmpty) {
                      // Set flag to prevent multiple triggers
                      _isProcessingResult = true;

                      _speechToText.stop();
                      setState(() {
                        _spokenWord = recognized;
                        _showMic = true;
                      });
                      _checkPronunciation(word, recognized);
                    }
                  },
                  localeId: 'en_US',
                );

                // Set a timeout - if no response in 5 seconds, prompt to click speak again
                Future.delayed(Duration(seconds: 5), () {
                  if (!mounted) return;
                  if (_speechToText.isListening && !_isProcessingResult) {
                    _speechToText.stop();
                    setState(() {
                      _spokenWord = 'Click "Speak" to try again';
                      _showMic = false;  // Turn off mic animation
                      _countdown = 0;    // Reset countdown
                    });

                    // Optional: Display a snackbar prompt
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No speech detected. Click "Speak" to try again.',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              }



              void _checkPronunciation(String word, String recognizedWord) async {
                if (!mounted) return;

                if (recognizedWord == word.toLowerCase()) {
                  await flutterTts.stop();
                  await _audioPlayer.stop();

                  _displayFeedback('Correct! 🎉', Colors.green, "Correct! Good Job!",
                      'alphabet-sounds/correct.mp3');
                  _confettiController.play();
                  _updateScore();

                  setState(() {
                    _countdown = 0;
                    _showMic = false;
                    _isProcessingResult = false; // Reset flag
                  });
                } else {
                  await _speechToText.stop();
                  await flutterTts.stop();
                  await _audioPlayer.stop();

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Incorrect! ❌ Try again.',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  await _audioPlayer.play(AssetSource('alphabet-sounds/wrong.mp3'));
                  await flutterTts.speak("Incorrect! Try again.");
                  await flutterTts.awaitSpeakCompletion(true);

                  if (mounted) {
                    setState(() {
                      _spokenWord = 'Listening...';
                      _showMic = true;
                      _isProcessingResult = false; // Reset flag before new listening
                    });

                    Future.delayed(Duration(milliseconds: 500), () {
                      if (mounted) {
                        _startListening(word);
                      }
                    });
                  }


                  // Always restart listening after a delay, regardless of message
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _spokenWord = 'Listening...';
                        _showMic = true;
                      });
                      _startListening(word);
                    }
                  });
                }
              }

              void _displayFeedback(
                  String message, Color color, String ttsMessage, String sound) async {
                if (!mounted) return;

                setState(() {
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // ✅ Clear previous message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                      ),
                      backgroundColor: color,
                      duration: Duration(seconds: 2),
                    ),
                  );
                });

                _speak(ttsMessage);
                await _audioPlayer.play(AssetSource(sound));
              }

              int _currentWordIndex = 0;

              // ✅ Fix: Stops previous sound & plays the current word instantly
              void _nextWord() async {
                await flutterTts.stop();
                await _audioPlayer.stop();

                setState(() {
                  if (_currentWordIndex < (vowelWords[widget.vowel]?.length ?? 1) - 1) {
                    _currentWordIndex++;
                    _spokenWord = '';
                  }
                });

                _startCountdown(vowelWords[widget.vowel]![_currentWordIndex]);
              }

              void _prevWord() async {
                await flutterTts.stop();
                await _audioPlayer.stop();

                setState(() {
                  if (_currentWordIndex > 0) {
                    _currentWordIndex--;
                    _spokenWord = '';
                  }
                });

                _startCountdown(vowelWords[widget.vowel]![_currentWordIndex]);
              }

            // Modified _onSpeakButtonPressed to maintain mic state
              void _onSpeakButtonPressed(String word) async {
                await flutterTts.stop();
                await _speechToText.stop();

                _isProcessingResult = false; // Reset flag
                _countdownTimer?.cancel();

                setState(() {
                  _spokenWord = '';
                  _showMic = true;
                  _countdown = 5;
                  _hasShownIncorrectMessage = false;
                });

                await _speak("Say the word: $word");
                _startCountdown(word);
              }

              @override
              Widget build(BuildContext context) {
                List<String> words = vowelWords[widget.vowel] ?? [];
                String currentWord = words[_currentWordIndex];

                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.pinkAccent, // Pink accent background
                    iconTheme: IconThemeData(color: Colors.white), // Black icons
                    title: Text(
                      '${widget.vowel} Vowel Words',
                      style: GoogleFonts.poppins(
                          fontSize: 28, color: Colors.white), // Black text
                    ),
                  ),
                  body: Stack(
                    children: [
                      // Background
                      Positioned.fill(
                        child: Image.asset(
                          'assets/background1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Confetti Effect 🎉
                      Positioned.fill(
                        child: IgnorePointer(
                          // ❗ Ensures confetti does not block button interactions
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            // 💥 More natural explosion
                            blastDirection: -3.14 / 2,
                            // 🔼 Confetti shoots UP
                            emissionFrequency: 0.05,
                            // 🎆 Smooth burst timing
                            numberOfParticles: 70,
                            // 💥 Bigger celebration effect
                            gravity: 0.08,
                            // 🌟 Slower so confetti stays visible longer
                            maxBlastForce: 70,
                            // 🚀 Confetti reaches front & top of screen
                            minBlastForce: 40,
                            // 🎇 Adds variation for realism
                            colors: [
                              Colors.red,
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.purple,
                              Colors.yellow,
                              Colors.white
                            ], // 🎨 More vibrant colors
                          ),
                        ),
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // The current word display with improved size and style
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            // Horizontal padding for better alignment
                            child: Container(
                              padding: EdgeInsets.all(10),
                              // Padding inside the container to create space around the text
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // Solid white background for the container
                                borderRadius: BorderRadius.circular(15),
                                // Rounded corners for the background
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    // Subtle shadow behind the container
                                    offset: Offset(2, 4),
                                    // Position of the shadow
                                    blurRadius: 6, // Blurring of the shadow for a soft look
                                  ),
                                ],
                              ),
                              child: Text(
                                currentWord,
                                textAlign: TextAlign.center, // Center the text
                                style: GoogleFonts.poppins(
                                  fontSize: 50, // Large font size
                                  fontWeight: FontWeight.normal, // Removed bold styling
                                  color: Colors.black, // Black text
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.grey.shade600, // Subtle shadow for text
                                      offset:
                                          Offset(3, 3), // Offset to create a lifted effect
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),
                          // Spacing between the word and the mic/button
                          // Word tile including the countdown and mic icon
                          _wordTile(currentWord),
                          SizedBox(height: 20),
                          // Spacing between buttons and word tile
                          // Row of navigation buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            // Padding for the buttons
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _prevWord,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    // Black button background
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    // Increased padding for button size
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: Text(
                                    "Previous",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.black), // White text
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _nextWord,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    // Black button background
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    // Increased padding for button size
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: Text(
                                    "Next",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.black), // White text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              // Update the UI part to not show "Try again" message
              Widget _wordTile(String word) {
                bool isButtonDisabled = _currentWord == word && _countdown > 0;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white.withOpacity(0.9),
                  child: Column(
                    children: [
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.pinkAccent),
                          onPressed: () => _speak(word),
                        ),
                        title: Text(
                          word,
                          style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isButtonDisabled ? null : () => _startCountdown(word),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonDisabled ? Colors.grey : Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _currentWord == word && _countdowns[word]! > 0
                              ? Text(
                            '${_countdowns[word]}',
                            style: GoogleFonts.poppins(
                                fontSize: 24, color: Colors.white),
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic, color: Colors.white),
                              SizedBox(width: 5),
                              Text('Speak',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      if (_currentWord == word)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              // Show countdown if it's greater than 0
                              if (_countdown > 0)
                                AnimatedScale(
                                  scale: 1.5,
                                  duration: Duration(milliseconds: 300), // Scale effect
                                  child: Text(
                                    '$_countdown',
                                    style: GoogleFonts.poppins(
                                        fontSize: 50, color: Colors.pinkAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              // Show the spoken word if it's not empty and it's not "Listening..."
                              if (_spokenWord.isNotEmpty &&
                                  _spokenWord != 'Listening...' &&
                                  !_spokenWord.startsWith("Say the word"))
                                Text(
                                  _spokenWord,
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.pinkAccent),
                                  textAlign: TextAlign.center,
                                ),
                              // Show "Listening..." when mic is active
                              if (_showMic && _spokenWord == 'Listening...')
                                Text(
                                  _spokenWord,
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.pinkAccent),
                                  textAlign: TextAlign.center,
                                ),
                              // Glowing mic
                              AvatarGlow(
                                glowColor: Colors.pinkAccent,
                                animate: _showMic, // Mic glows while listening
                                child: Icon(Icons.mic, size: 40, color: Colors.pinkAccent),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }
            }

                import 'dart:async';
                import 'dart:math';
                import 'package:flutter/material.dart';
                import 'package:flutter_tts/flutter_tts.dart';
                import 'package:speech_to_text/speech_to_text.dart' as stt;
                import 'package:permission_handler/permission_handler.dart';

                class CheckPronunciationScreen extends StatefulWidget {
                  const CheckPronunciationScreen({Key? key}) : super(key: key);

                  @override
                  _CheckPronunciationScreenState createState() =>
                      _CheckPronunciationScreenState();
                }

                class _CheckPronunciationScreenState extends State<CheckPronunciationScreen>
                    with SingleTickerProviderStateMixin {
                  final FlutterTts _flutterTts = FlutterTts();
                  final stt.SpeechToText _speechToText = stt.SpeechToText();
                  bool _isListening = false;
                  bool _speechEnabled = false;
                  String _spokenWord = '';
                  String _targetWord = '';
                  String? _previousWord; // To store the previous word for "Back Word"
                  bool _isSpeaking = false;
                  bool _isDetectingSpeech = false;

                  bool _isLoading = true; // To show the loading screen for 1 second

                  final List<String> _basicWords = [
                    'apple', 'banana', 'cat', 'dog', 'egg', 'fish', 'goat', 'house', 'ice',
                    'jam', 'kite', 'lamp', 'mouse', 'nest', 'orange', 'pen', 'queen', 'rabbit',
                    'sun', 'three', 'umbrella', 'van', 'water', 'x-ray', 'yellow', 'zebra'
                  ];

                  AnimationController? _micController;
                  Animation<double>? _micAnimation;

                  @override
                  void initState() {
                    super.initState();
                    _micController = AnimationController(
                      vsync: this,
                      duration: const Duration(milliseconds: 500),
                    )..repeat(reverse: true);
                    _micAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(_micController!);

                    _showLoadingScreen();
                  }

                  @override
                  void dispose() {
                    _micController?.dispose();
                    super.dispose();
                  }

                  Future<void> _showLoadingScreen() async {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _isLoading = false;
                    });
                    await _requestPermissions(); // Start the flow after loading screen
                    _selectRandomWord(); // Select the first random word
                    _speakWord(); // Speak the first word
                  }

                  Future<void> _requestPermissions() async {
                    var status = await Permission.microphone.request();
                    if (status.isGranted) {
                      await _initializeSpeechRecognition();
                    } else {
                      _showErrorDialog(
                          'Microphone permission is required. Please enable it in settings.');
                    }
                  }

                  Future<void> _initializeSpeechRecognition() async {
                    bool isInitialized = await _speechToText.initialize(
                      onStatus: (status) => print('Speech status: $status'),
                      onError: (error) => print('Speech recognition error: ${error.errorMsg}'),
                    );

                    if (!isInitialized) {
                      _showErrorDialog('Speech recognition is not available on this device.');
                    }

                    setState(() {
                      _speechEnabled = isInitialized;
                    });
                  }

                  void _selectRandomWord() {
                    _previousWord = _targetWord; // Save the current word as the previous word
                    final randomIndex = Random().nextInt(_basicWords.length);
                    setState(() {
                      _targetWord = _basicWords[randomIndex];
                    });
                  }

                  Future<void> _speakWord() async {
                    setState(() {
                      _isSpeaking = true;
                      _spokenWord = ''; // Reset spoken word
                    });

                    // Disable listening while TTS is speaking
                    await _speechToText.stop();

                    await _flutterTts.setLanguage('en-US');
                    await _flutterTts.setSpeechRate(0.5);
                    await _flutterTts.setPitch(1.0);
                    await _flutterTts.speak('Say the word $_targetWord, now, your turn!');
                    _flutterTts.setCompletionHandler(() {
                      setState(() => _isSpeaking = false);
                      _startListening(); // Start listening after TTS completes
                    });
                  }

                  void _startListening() async {
                    if (!_speechEnabled || _isSpeaking) return;

                    setState(() {
                      _isListening = true;
                      _spokenWord = ''; // Clear any previous word
                    });

                    try {
                      await _speechToText.listen(
                        localeId: 'en_US',
                        onSoundLevelChange: (level) {
                          setState(() {
                            _isDetectingSpeech = level > 0.5; // Adjust threshold as needed
                          });
                        },
                        onResult: (result) {
                          setState(() {
                            _spokenWord = result.recognizedWords.trim();
                          });

                          if (result.finalResult) {
                            _checkPronunciation(); // Check pronunciation when a result is finalized
                            Future.delayed(const Duration(milliseconds: 300), () {
                              _startListening(); // Restart listening after processing the result
                            });
                          }
                        },
                      );
                    } catch (e) {
                      setState(() {
                        _isListening = false;
                      });
                      _showErrorDialog('Speech recognition failed: $e');
                    }
                  }


                  void _checkPronunciation() async {
                    if (_spokenWord.toLowerCase() == _targetWord.toLowerCase()) {
                      setState(() {
                        _isListening = false; // Stop listening immediately
                      });

                      // Speak "Correct!" and update UI synchronously
                      await _flutterTts.speak('Correct!');
                      _showMessage('Correct! Well done!', Colors.green);

                      // Automatically move to the next word
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _selectRandomWord();
                        _speakWord();
                      });
                    } else {
                      // Handle incorrect pronunciation
                      setState(() {
                        _isListening = true; // Restart listening
                      });

                      // Speak "Incorrect!" and allow retry
                      await _flutterTts.speak('Incorrect! Try again.');
                      _showMessage('Incorrect! Try again.', Colors.red);

                      // Restart listening for the same word
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _startListening();
                      });
                    }
                  }

                  void _goBackToPreviousWord() {
                    if (_previousWord != null) {
                      setState(() {
                        _targetWord = _previousWord!;
                        _spokenWord = ''; // Reset spoken word
                      });
                      _speakWord();
                    } else {
                      _showMessage('No previous word available!', Colors.orange);
                    }
                  }

                  void _showMessage(String message, Color color) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          message,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: color,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  void _showErrorDialog(String message) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }

                  Widget _buildLoadingScreen() {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/background1.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  @override
                  Widget build(BuildContext context) {
                    if (_isLoading) {
                      return Scaffold(body: _buildLoadingScreen());
                    }

                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                          'Check Pronunciation',
                          style: TextStyle(color: Colors.white), // Set the title text color to white
                        ),
                        iconTheme: IconThemeData(color: Colors.white), // Set the back button color to white
                        backgroundColor: Colors.pinkAccent, // Keep the pink background
                      ),
                      body: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/background1.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_isSpeaking) ...[
                                  const Text(
                                    'Say the word:',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    _targetWord.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                if (_isListening)
                                  Column(
                                    children: [
                                      ScaleTransition(
                                        scale: _isDetectingSpeech
                                            ? _micAnimation!
                                            : AlwaysStoppedAnimation(1.0),
                                        child: const Icon(
                                          Icons.mic,
                                          size: 100,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      const Text(
                                        'Listening...',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_spokenWord.isNotEmpty)
                                  Text(
                                    'You said: "${_spokenWord.toUpperCase()}"',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _spokenWord.toLowerCase() == _targetWord.toLowerCase()
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _goBackToPreviousWord,
                                      child: const Text('Back Word'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _selectRandomWord();
                                        _speakWord();
                                      },
                                      child: const Text('Next Word'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _speakWord,
                                  child: const Text('Play Again'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }

              import 'package:flutter/material.dart';
              import 'package:audioplayers/audioplayers.dart';
              import 'package:google_fonts/google_fonts.dart';
              import 'package:flutter_tts/flutter_tts.dart';
              import 'package:confetti/confetti.dart';
              import 'package:shared_preferences/shared_preferences.dart';

              class TheZooScreen extends StatefulWidget {
                final AudioPlayer audioPlayer;

                const TheZooScreen({Key? key, required this.audioPlayer}) : super(key: key);

                @override
                _TheZooScreenState createState() => _TheZooScreenState();
              }

              class _TheZooScreenState extends State<TheZooScreen> with SingleTickerProviderStateMixin {
                final FlutterTts _flutterTts = FlutterTts();
                bool _isLoading = true;
                late AnimationController _animationController;
                late Animation<Offset> _slideAnimation;
                late ConfettiController _confettiController;
                AudioPlayer _soundPlayer = AudioPlayer();

                final List<TextEditingController> _controllers = List.generate(
                    6, (_) => TextEditingController());
                final List<String> _correctAnswers = ["Yes", "Wild animals", "Zebra, Tiger, Lion, Crocodile", "No", "Zookeeper", "Give them food"];
                final List<bool?> _isCorrect = List.filled(6, null);
                List<String> _history = [];

                @override
                void initState() {
                  super.initState();
                  _confettiController = ConfettiController(duration: Duration(seconds: 3));
                  _animationController = AnimationController(
                      vsync: this, duration: Duration(milliseconds: 800));
                  _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
                      .animate(CurvedAnimation(
                      parent: _animationController, curve: Curves.easeInOut));
                  _startLoading();
                  _startNarration();
                  _loadHistory();
                }

                void _startLoading() async {
                  await Future.delayed(Duration(seconds: 1));
                  setState(() {
                    _isLoading = false;
                  });
                  _animationController.forward();
                }

                Future<void> _startNarration() async {
                  await _flutterTts.setLanguage("en-US");
                  await _flutterTts.setSpeechRate(0.4);
                  await _flutterTts.speak(
                    "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
                  );
                }

                final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

                void _checkAnswers() async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  _history.clear();
                  int score = 0;

                  setState(() {
                    for (int i = 0; i < _controllers.length; i++) {
                      String userAnswer = _controllers[i].text.trim().toLowerCase();
                      String correct = _correctAnswers[i].toLowerCase();

                      if (userAnswer == correct) {
                        _isCorrect[i] = true;
                        _history.add("Q${i + 1}: Correct ✅");
                        score++;
                      } else if (userAnswer.isEmpty) {
                        _isCorrect[i] = null; // Allow empty inputs
                      } else {
                        _isCorrect[i] = false;
                        _history.add("Q${i + 1}: Wrong ❌");
                      }
                    }
                    prefs.setStringList("zoo_history", _history);
                  });

                  String stars = _getStars(score);

                  if (score == 6) {
                    _confettiController.play();
                    await _soundPlayer.stop();
                    await _soundPlayer.play(AssetSource('stories/sound/win.mp3'));
                    _showResult("assets/stories/trophy.gif", "Congratulations! 🎉", score);
                  } else if (score >= 3) {
                    _confettiController.play();
                    await _soundPlayer.stop();
                    await _soundPlayer.play(AssetSource('stories/sound/win.mp3'));
                    _showResult("assets/stories/trophy.gif", "Great Job! 🎯", score);
                  } else {
                    await _soundPlayer.stop();
                    await _soundPlayer.play(AssetSource('stories/sound/gameover.mp3'));
                    _showResult("assets/stories/tryagain.gif", "Try Again! ❌", score);
                  }

                  _clearAnswers();
                }

                void _clearAnswers() {
                  for (int i = 0; i < _controllers.length; i++) {
                    _controllers[i].clear();
                    if (i < _controllers.length - 1) {
                      _focusNodes[i + 1].requestFocus(); // Automatic scroll to next input field
                    }
                  }
                  FocusScope.of(context).unfocus(); // Close keyboard after the last input
                }



                Future<void> _loadHistory() async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _history = prefs.getStringList("zoo_history") ?? [];
                  });
                }


                String _getStars(int score) {
                  switch (score) {
                    case 6:
                      return "⭐⭐⭐⭐⭐⭐";
                    case 5:
                      return "⭐⭐⭐⭐⭐";
                    case 4:
                      return "⭐⭐⭐⭐";
                    case 3:
                      return "⭐⭐⭐";
                    case 2:
                      return "⭐⭐";
                    case 1:
                      return "🌟";
                    default:
                      return "No Stars ❌";
                  }
                }


                void _showResult(String imagePath, String message, int score) {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 22, color: Colors.pinkAccent),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(imagePath, width: 200, height: 200),
                              SizedBox(height: 10),
                              Text(
                                "Your Score: $score/6\n${_getStars(score)}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.black),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  _soundPlayer.stop(); // Stop sound on close
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.pinkAccent),
                                child: Text(
                                  "Close",
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                }


                @override
                void dispose() {
                  _confettiController.dispose();
                  _animationController.dispose();
                  _flutterTts.stop();
                  _soundPlayer.dispose();
                  _controllers.forEach((controller) => controller.dispose());
                  super.dispose();
                }

                @override
                Widget build(BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.pinkAccent,
                      title: Text(
                        'Stories 📚',
                        style: GoogleFonts.poppins(
                            fontSize: 28, color: Colors.white),
                      ),
                      iconTheme: IconThemeData(color: Colors.white),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.history),
                          onPressed: _showHistory,
                          tooltip: 'School History',
                        ),
                      ],
                    ),
                    body: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/background1.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          colors: [Colors.green, Colors.blue, Colors.pink, Colors.yellow],
                        ),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                        else
                          SlideTransition(
                            position: _slideAnimation,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "The Zoo",
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.6), // Shadow for better readability
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                      background: Paint()
                                        ..color = Colors.pinkAccent.withOpacity(0.8) // Background Color
                                        ..strokeWidth = 40
                                        ..strokeJoin = StrokeJoin.round
                                        ..style = PaintingStyle.stroke, // Stroke style for better effect
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  _buildStory(),
                                  _buildQuestions(),
                                  ElevatedButton(
                                    onPressed: _checkAnswers,
                                    child: Text("Submit Answer",
                                        style: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pinkAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                bool _isPlaying = false; // Track TTS playing state

                Widget _buildStory() {
                  return Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/stories/the_zoo.jpg'),
                        SizedBox(height: 10),
                        Text(
                          "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        SizedBox(height: 20),

                        // Button Row with Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (_isPlaying) {
                                      await _flutterTts.pause();
                                      setState(() {
                                        _isPlaying = false;
                                      });
                                    } else {
                                      await _flutterTts.speak(
                                        "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
                                      );
                                      setState(() {
                                        _isPlaying = true;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: _isPlaying ? Colors.orange : Colors.green,
                                    size: 32,
                                  ),
                                  tooltip: _isPlaying ? 'Pause' : 'Play',
                                ),
                                Text(
                                  _isPlaying ? "Pause" : "Play",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await _flutterTts.stop();
                                    setState(() {
                                      _isPlaying = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.stop,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  tooltip: 'Stop',
                                ),
                                Text(
                                  "Stop",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }


                Widget _buildQuestions() {
                  List<String> questions = [
                    "Have you been to the zoo?",
                    "What do you see in a zoo?",
                    "Give examples of wild animals?",
                    "Do animals like to live in the zoo?",
                    "Who keeps the animals well?",
                    "How can you help animals?"
                  ];

                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Column(
                      children: List.generate(questions.length, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                questions[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textInputAction: index == questions.length - 1
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                onSubmitted: (_) {
                                  if (index < questions.length - 1) {
                                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Your Answer",
                                  suffixIcon: _isCorrect[index] == null
                                      ? null
                                      : Icon(
                                    _isCorrect[index]! ? Icons.check_circle : Icons.close,
                                    color: _isCorrect[index]! ? Colors.green : Colors.red,
                                    size: 24,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                }

                void _showHistory() {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: Text(
                            'School History 🏫',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 24, color: Colors.pinkAccent),
                          ),
                          content: Container(
                            height: 300,
                            width: double.maxFinite,
                            child: _history.isEmpty
                                ? Center(
                              child: Text(
                                "No History Available 📜",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.grey),
                              ),
                            )
                                : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: Colors.white.withOpacity(0.9),
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      _history[index].contains("Correct") ? Icons
                                          .check_circle : Icons.close,
                                      color: _history[index].contains("Correct") ? Colors
                                          .green : Colors.red,
                                      size: 28,
                                    ),
                                    title: Text(
                                      _history[index],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: _history[index].contains("Correct") ? Colors
                                            .green : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton.icon(
                              onPressed: () => _confirmDelete(),
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              label: Text(
                                "Delete",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.redAccent),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, color: Colors.pinkAccent),
                              label: Text(
                                "Close",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.pinkAccent),
                              ),
                            ),
                          ],
                        ),
                  );
                }

                void _confirmDelete() {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: Text(
                            "Delete Confirmation",
                            style: GoogleFonts.poppins(
                                fontSize: 22, color: Colors.redAccent),
                          ),
                          content: Text(
                            "Are you sure you want to delete all history? This action cannot be undone.",
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.blueAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteHistory();
                                Navigator.of(context).pop(); // Close Confirmation
                                Navigator.of(context).pop(); // Close History
                              },
                              child: Text(
                                "Delete",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                  );
                }

                Future<void> _deleteHistory() async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _history.clear();
                    prefs.remove("zoo_history");
                  });
                }
              }

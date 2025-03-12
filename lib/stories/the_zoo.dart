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

class _TheZooScreenState extends State<TheZooScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;
  late ConfettiController _dialogConfettiController;
  AudioPlayer _soundPlayer = AudioPlayer();

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<List<String>> _correctAnswers = [
    ["Yes", "I have", "I’ve been to the zoo", "I have visited a zoo"],
    [
      "Wild animals",
      "animals",
      "Different animals",
      "Various animals",
      "Zoo animals"
    ],
    [
      "zebra tiger lion crocodile eagle monkey large fishes ostrich",
      "lions tigers zebras crocodiles eagles monkeys fishes ostrich",
      "lions zebras tigers eagles monkeys",
      "crocodiles tigers lions zebras monkeys",
      "tigers lions zebras crocodiles fishes",
      "eagles monkeys lions tigers ostrich",
      "monkeys eagles large fishes crocodiles zebras",
      "fishes tigers zebras crocodiles lions",
      "ostrich tigers monkeys eagles zebras",
      "zebra tiger lion monkey eagle ostrich large fishes crocodile",
      "zebras tigers lions monkeys crocodiles ostrich fishes eagles",
      "monkeys lions zebras fishes tigers eagles ostrich"
    ],
    ["No", "I don't think so", "I think they don’t", "Animals don’t like it"],
    ["Zookeeper", "Zoo caretaker", "Animal caretaker", "Zoo staff"],
    [
      "Give them food",
      "Feed them",
      "Provide food",
      "Give them proper food",
      "Make sure they have food and water"
    ]
  ];

  final List<bool?> _isCorrect = List.filled(6, null);
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _dialogConfettiController =
        ConfettiController(duration: Duration(seconds: 2));
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    _startLoading();
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
    await _flutterTts.setPitch(0.9);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.speak(
        "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.");
  }

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _showRestartButton =
      false; // ✅ Track if restart button should be visible

  void _checkAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _history.clear();
    int score = 0;

    setState(() {
      for (int i = 0; i < _controllers.length; i++) {
        String userAnswer = _controllers[i].text.trim();
        bool isCorrect = _correctAnswers[i]
            .any((answer) => answer.toLowerCase() == userAnswer.toLowerCase());

        if (isCorrect) {
          _isCorrect[i] = true;
          _history.add("Q${i + 1}: ✅ Correct - Your Answer: \"$userAnswer\"");
          score++;
        } else if (userAnswer.isEmpty) {
          _isCorrect[i] = null;
        } else {
          _isCorrect[i] = false;
          _history.add("Q${i + 1}: ❌ Wrong - Your Answer: \"$userAnswer\"");
        }
      }
    });

    prefs.setStringList("zoo_history", _history); // ✅ Save history locally

    String applauseSound = '';
    String winSound = 'stories/sound/win.mp3';

    if (score == 6) {
      applauseSound = 'rhyming_words/applause_youdid.mp3';
      _confettiController.play();
      _dialogConfettiController.play();
      _showResult("assets/stories/trophy.gif", "Congratulations! 🎉", score,
          showRestart: true);
    } else if (score == 4) {
      applauseSound = 'rhyming_words/applause_excellent.mp3';
      _confettiController.play();
      _dialogConfettiController.play();
      _showResult("assets/stories/trophy.gif", "Excellent Work! 🌟", score,
          showRestart: true);
    } else if (score == 3) {
      applauseSound = 'rhyming_words/applause_greatjob.mp3';
      _confettiController.play();
      _dialogConfettiController.play();
      _showResult("assets/stories/trophy.gif", "Great Job! 🎯", score,
          showRestart: true);
    } else {
      winSound = 'stories/sound/gameover.mp3';
      _showResult("assets/stories/tryagain.gif", "Try Again! ❌", score,
          showRestart: true);
    }

    if (score >= 3) {
      AudioPlayer winPlayer = AudioPlayer();
      AudioPlayer applausePlayer = AudioPlayer();

      winPlayer.play(AssetSource(winSound));
      applausePlayer.play(AssetSource(applauseSound));
    } else {
      await _soundPlayer.play(AssetSource(winSound)); // ✅ Plays gameover sound
    }
  }

  void _restartQuiz() async {
    AudioPlayer tapPlayer = AudioPlayer();
    await tapPlayer.play(AssetSource('alphabet-sounds/tap.mp3'));

    setState(() {
      for (int i = 0; i < _controllers.length; i++) {
        _controllers[i].clear();
        _isCorrect[i] = null;
      }
    });
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

  void _showResult(String imagePath, String message, int score,
      {bool showRestart = false}) {
    if (score >= 3) {
      // ✅ Show confetti only if score is 3 or more (correct answers)
      _dialogConfettiController.play();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(imagePath, width: 100),
                  SizedBox(height: 10),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your Score: $score/6",
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 20),
                  if (showRestart)
                    ElevatedButton(
                      onPressed: () {
                        _stopAllSounds(); // ✅ Stop all sounds before restarting
                        Navigator.pop(context);
                        _restartQuiz();
                      },
                      child: Text("Restart Quiz",
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                    ),
                ],
              ),
            ),

            // ✅ Fireworks Confetti Animation
            ConfettiWidget(
              confettiController: _dialogConfettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.2,
              numberOfParticles: 30,
              gravity: 0.3,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            ),
          ],
        );
      },
    ).then((_) => _stopAllSounds()); // ✅ Stops sounds when closing the modal
  }

  void _stopAllSounds() async {
    await _flutterTts.stop(); // ✅ Stops TTS if playing
    await _soundPlayer.stop(); // ✅ Stops any ongoing sound effects
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _dialogConfettiController.dispose();
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
          style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
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
                            color: Colors.black.withOpacity(0.6),
                            // Shadow for better readability
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                        background: Paint()
                          ..color = Colors.pinkAccent
                              .withOpacity(0.8) // Background Color
                          ..strokeWidth = 40
                          ..strokeJoin = StrokeJoin.round
                          ..style = PaintingStyle
                              .stroke, // Stroke style for better effect
                      ),
                      textAlign: TextAlign.center,
                    ),
                    _buildStory(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        padding: EdgeInsets.all(8), // ✅ Adds spacing inside
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "📢 Note: At least 3 scores to win!",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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

  bool _isPlaying = false;
  final AudioPlayer _tapPlayer = AudioPlayer(); // ✅ Added Tap Sound Player

  Widget _buildStory() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
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
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 20),

          // ✅ Play → Stop & Restart (Instant switch with tap sound)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.pinkAccent, // ✅ Background for buttons
              borderRadius: BorderRadius.circular(12),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isPlaying) // ✅ Show Play button first
                      TextButton.icon(
                        onPressed: () async {
                          await _tapPlayer.play(AssetSource(
                              'alphabet-sounds/tap.mp3')); // ✅ Play tap sound
                          setState(() => _isPlaying = true);
                          await _flutterTts.setLanguage("en-US");
                          await _flutterTts.setPitch(0.9);
                          await _flutterTts.setSpeechRate(0.4);
                          await _flutterTts.speak(
                            "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
                          );
                        },
                        icon: Icon(Icons.play_arrow, color: Colors.white),
                        label: Text("Play",
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.white)),
                      ),
                    if (_isPlaying) ...[
                      TextButton.icon(
                        onPressed: () async {
                          await _tapPlayer.play(AssetSource(
                              'alphabet-sounds/tap.mp3')); // ✅ Play tap sound
                          await _flutterTts.stop();
                          setState(() => _isPlaying = false);
                        },
                        icon: Icon(Icons.stop, color: Colors.red),
                        // 🛑 Red Stop Icon
                        label: Text("Stop",
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () async {
                          await _tapPlayer.play(AssetSource(
                              'alphabet-sounds/tap.mp3')); // ✅ Play tap sound
                          await _flutterTts.stop();
                          await _flutterTts.speak(
                            "Have you been to the zoo? What do you see in the zoo? In the zoo, we see wild animals. We see a zebra, a tiger, a lion, and a crocodile. We also see other animals like eagles, monkeys, large fishes, and ostrich.",
                          );
                        },
                        icon: Icon(Icons.refresh, color: Colors.blue),
                        // 🔄 Blue Restart Icon
                        label: Text("Restart",
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    List<String> questions = [
      "Have you been to the zoo?",
      "What do you see in a zoo?",
      "Give examples of wild animals that you can see there?",
      "Do yo think animals like to live in the zoo?",
      "Who keeps the animals in the zoo well?",
      "How can you help or what can you do to the animals in the zoo to survive for a long time"
    ];

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
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
                      fontSize: 18, color: Colors.blueAccent),
                ),
                TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Your Answer",
                    suffixIcon: _isCorrect[index] == null
                        ? null
                        : Icon(
                            _isCorrect[index]!
                                ? Icons.check_circle
                                : Icons.close,
                            color:
                                _isCorrect[index]! ? Colors.green : Colors.red,
                            size: 24,
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
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
      builder: (_) => AlertDialog(
        title: Text(
          'School History 🏫',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 24, color: Colors.pinkAccent),
        ),
        content: Container(
          height: 300,
          width: double.maxFinite,
          child: _history.isEmpty
              ? Center(
                  child: Text(
                    "No History Available 📜",
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    bool isCorrect = _history[index].contains("✅ Correct");
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isCorrect ? Icons.check_circle : Icons.close,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 28,
                        ),
                        title: Text(
                          _history[index],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: isCorrect ? Colors.green : Colors.red,
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
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.redAccent),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.pinkAccent),
            label: Text(
              "Close",
              style:
                  GoogleFonts.poppins(fontSize: 18, color: Colors.pinkAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Delete Confirmation",
          style: GoogleFonts.poppins(fontSize: 22, color: Colors.redAccent),
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
              style:
                  GoogleFonts.poppins(fontSize: 18, color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _deleteHistory(); // ✅ Delete history
              Navigator.of(context).pop(); // Close Confirmation Dialog
              Navigator.of(context).pop(); // Close History Dialog
              _showDeleteSuccess(); // ✅ Show success dialog
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Success ✅",
          style: GoogleFonts.poppins(fontSize: 22, color: Colors.green),
        ),
        content: Text(
          "History has been successfully deleted!",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "OK",
              style:
                  GoogleFonts.poppins(fontSize: 18, color: Colors.blueAccent),
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

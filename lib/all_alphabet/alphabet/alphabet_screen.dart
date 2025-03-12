import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class AlphabetScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  AlphabetScreen({required this.audioPlayer});

  @override
  _AlphabetScreenState createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  bool _showWelcomeScreen = true;

  static const Map<String, String> _examples = {
    'A': 'Apple',
    'B': 'Basketball',
    'C': 'Cat',
    'D': 'Dog',
    'E': 'Eggplant',
    'F': 'Flower',
    'G': 'Guitar',
    'H': 'Hat',
    'I': 'Igloo',
    'J': 'Jacket',
    'K': 'Key',
    'L': 'Lion',
    'M': 'Monkey',
    'N': 'Nails',
    'O': 'Orange',
    'P': 'Pig',
    'Q': 'Queen',
    'R': 'Rabbit',
    'S': 'Sun',
    'T': 'Turtle',
    'U': 'Umbrella',
    'V': 'Vase',
    'W': 'Watermelon',
    'X': 'Xylophone',
    'Y': 'Yoyo',
    'Z': 'Zebra',
  };

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _showLoadingScreen();
  }

  Future<void> _setupTTS() async {
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('en-US');
  }

  Future<void> _showLoadingScreen() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _showWelcomeScreen = false;
    });
  }

  Future<void> _speakCurrentLetter() async {
    String letter = _examples.keys.elementAt(_currentIndex);
    String word = _examples[letter]!;
    String soundPath = 'alphabet-sounds/${letter.toLowerCase()}.mp3';

    try {
      // Stop any ongoing speech and sound before playing new letter
      await flutterTts.stop();
      await audioPlayer.stop();

      // Step 1: Speak the letter
      await flutterTts.speak(letter);
      await flutterTts.awaitSpeakCompletion(true);

      // Step 2: Speak "The sound is..."
      await flutterTts.speak("The sound is...");
      await flutterTts.awaitSpeakCompletion(true);

      // Step 3: Play the letter sound
      await audioPlayer.play(AssetSource(soundPath));
      await audioPlayer.onPlayerComplete.first; // Wait for sound to finish

      // Step 4: Speak "This word: Apple"
      await flutterTts.speak("$word");
      await flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      print('Error during TTS or audio playback for $letter: $e');
    }
  }

  Future<void> _scrollToCurrentIndex() async {
    double itemWidth = 80.0;
    double screenWidth = MediaQuery.of(context).size.width;

    double centerOffset =
        (_currentIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      centerOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    audioPlayer.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn Alphabets 📖',
          style: GoogleFonts.poppins(fontSize: 26, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _showWelcomeScreen ? _buildLoadingScreen() : _buildMainScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _speakCurrentLetter(),
                  child: Container(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/alphabets/${_examples.keys.elementAt(_currentIndex).toLowerCase()}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _examples.values.elementAt(_currentIndex),
                style: GoogleFonts.poppins(fontSize: 60, color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.black.withOpacity(0.6),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _examples.keys.length,
              itemBuilder: (context, index) {
                String letter = _examples.keys.elementAt(index);
                return GestureDetector(
                  onTap: () async {
                    // Stop previous sound and speech when a new letter is clicked
                    await flutterTts.stop();
                    await audioPlayer.stop();

                    setState(() {
                      _currentIndex = index;
                    });

                    await _speakCurrentLetter();
                    await _scrollToCurrentIndex();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: _currentIndex == index ? 80 : 60,
                    height: _currentIndex == index ? 80 : 60,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.pinkAccent : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentIndex == index ? Colors.deepPurple : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: GoogleFonts.poppins(
                          fontSize: _currentIndex == index ? 30 : 20,
                          fontWeight: FontWeight.bold,
                          color: _currentIndex == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

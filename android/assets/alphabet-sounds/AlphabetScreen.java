import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers package

class AlphabetScreen extends StatefulWidget {
  @override
  _AlphabetScreenState createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer(); // AudioPlayer instance
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
    'T': 'Tiger',
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
    _showWelcomeMessage();
  }

  Future<void> _setupTTS() async {
    await flutterTts.setSpeechRate(0.5); // Slower speech for clarity
    await flutterTts.setPitch(1.0); // Natural pitch
    await flutterTts.setLanguage('en-US'); // English language
  }

  Future<void> _showWelcomeMessage() async {
    try {
      // Speak the welcome message
      await flutterTts.speak('Hello! Welcome to AlphaSpeak, your guided alphabet learning app!');
      // Wait for TTS to finish before proceeding
      await flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      print('Error during welcome message: $e');
    }

    // Once the message is done, hide the welcome screen
    setState(() {
      _showWelcomeScreen = false;
    });
  }


  Future<void> _speakCurrentLetter() async {
    String letter = _examples.keys.elementAt(_currentIndex);
    String word = _examples[letter]!;
    String soundPath = 'alphabet-sounds/${letter.toLowerCase()}.mp3';

    try {
      print('Speaking: $letter is for $word');
      await flutterTts.speak('$letter is for $word');
      await flutterTts.awaitSpeakCompletion(true);

      print('TTS completed, now playing sound: $soundPath');
      await audioPlayer.stop(); // Stop current playback if any
      await audioPlayer.play(AssetSource(soundPath)); // Play the file
      print('Sound playing: $soundPath');
    } catch (e) {
      print('Error playing sound or TTS for $letter: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn Alphabets'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _showWelcomeScreen ? _buildWelcomeScreen() : _buildMainScreen(),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Message
          Text(
            'Hello! Welcome to AlphaSpeak, your guided alphabet learning app!',
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
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Loading Indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Center Image and Letter
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _examples.keys.elementAt(_currentIndex),
                style: TextStyle(
                  fontSize: 120,
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
              SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _speakCurrentLetter(); // Play sound and TTS on tap
                  },
                  child: Container(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/alphabets/${_examples.keys.elementAt(_currentIndex).toLowerCase()}.png',
                      fit: BoxFit.contain, // Keeps original aspect ratio
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _examples.values.elementAt(_currentIndex),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
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

        // Bottom Carousel
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.black.withOpacity(0.6), // Semi-transparent overlay
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _examples.keys.length,
              itemBuilder: (context, index) {
                String letter = _examples.keys.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    _speakCurrentLetter();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: _currentIndex == index ? 80 : 60,
                    height: _currentIndex == index ? 80 : 60,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.pinkAccent
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentIndex == index
                            ? Colors.deepPurple
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: _currentIndex == index ? 30 : 20,
                          fontWeight: FontWeight.bold,
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.black,
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
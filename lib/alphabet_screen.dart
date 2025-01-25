import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AlphabetScreen extends StatefulWidget {
  @override
  _AlphabetScreenState createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer(); // AudioPlayer instance
  final ScrollController _scrollController = ScrollController(); // ScrollController for the carousel

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
    _showLoadingScreen();
  }

  Future<void> _setupTTS() async {
    await flutterTts.setSpeechRate(0.5); // Slower speech for clarity
    await flutterTts.setPitch(1.0); // Natural pitch
    await flutterTts.setLanguage('en-US'); // English language
  }

  Future<void> _showLoadingScreen() async {
    // Simulate a 0.5-second loading period
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _showWelcomeScreen = false;
    });
  }

  Future<void> _speakCurrentLetter() async {
    String letter = _examples.keys.elementAt(_currentIndex);
    String word = _examples[letter]!;
    String soundPath = 'alphabet-sounds/${letter.toLowerCase()}.mp3';

    try {
      // Stop any ongoing TTS and audio playback before proceeding
      await flutterTts.stop();
      await audioPlayer.stop();

      // Speak the letter and word
      print('Speaking: $letter is for $word, the sound is');
      await flutterTts.speak('$letter is for $word, the sound is');
      await flutterTts.awaitSpeakCompletion(true);

      // Play the sound immediately after speaking
      print('Playing sound: $soundPath');
      await audioPlayer.play(AssetSource(soundPath)); // Play the MP3 file
    } catch (e) {
      print('Error during TTS or audio playback for $letter: $e');
    }
  }

  Future<void> _scrollToCurrentIndex() async {
    double itemWidth = 80.0; // Width of each letter in the carousel
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the scroll offset to center the current letter
    double centerOffset = (_currentIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    // Smooth scroll to make the current index centered
    _scrollController.animateTo(
      centerOffset.clamp(0, _scrollController.position.maxScrollExtent), // Clamp to valid range
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
              // Removed the letter above the image
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _speakCurrentLetter();
                  },
                  child: Container(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/alphabets/${_examples.keys.elementAt(_currentIndex).toLowerCase()}.png',
                      fit: BoxFit.contain,
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
                    setState(() {
                      _currentIndex = index;
                    });
                    await _speakCurrentLetter();
                    await _scrollToCurrentIndex(); // Center the selected letter
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

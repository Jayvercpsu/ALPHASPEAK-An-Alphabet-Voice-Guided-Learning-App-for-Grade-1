import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker extends StatefulWidget {
  final Map<String, dynamic> progressData;
  final String username;
  final String section;
  final Function() onBackToHome;
  final Function(String, String) onProfileUpdate;

  const ProgressTracker({
    Key? key,
    required this.progressData,
    required this.username,
    required this.section,
    required this.onBackToHome,
    required this.onProfileUpdate,
  }) : super(key: key);

  @override
  _ProgressTrackerState createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> {
  late TextEditingController _usernameController;
  late TextEditingController _sectionController;
  bool _isEditing = false;
  Map<String, int> _rhymeScores = {'easy': 0, 'medium': 0, 'hard': 0};
  Map<String, int> _wordPuzzleScores = {'easy': 0, 'medium': 0, 'hard': 0};

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _sectionController = TextEditingController(text: widget.section);
    _loadRhymeScores();
  }

  Future<void> _loadRhymeScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rhymeScores['easy'] = prefs.getInt('easy_score') ?? 0;
      _rhymeScores['medium'] = prefs.getInt('medium_score') ?? 0;
      _rhymeScores['hard'] = prefs.getInt('hard_score') ?? 0;

      // Add these lines to load Word Puzzle scores
      _wordPuzzleScores['easy'] = prefs.getInt('easy_word_score') ?? 0;
      _wordPuzzleScores['medium'] = prefs.getInt('medium_word_score') ?? 0;
      _wordPuzzleScores['hard'] = prefs.getInt('hard_word_score') ?? 0;

    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        widget.onProfileUpdate(
          _usernameController.text.trim(),
          _sectionController.text.trim(),
        );
      }
    });
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: _isEditing
          ? Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _sectionController,
            decoration: InputDecoration(
              labelText: 'Section',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleEdit,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${widget.username}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Section: ${widget.section}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.deepOrange),
            onPressed: _toggleEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Overview',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          SizedBox(height: 16),
          _buildActivityProgress('Rhyming Words', widget.progressData['Rhyming Words']),
          SizedBox(height: 16),
          _buildActivityProgress('Word Puzzle', widget.progressData['Word Puzzle']),
          SizedBox(height: 16),
          _buildActivityProgress('Stories', widget.progressData['Stories']),
        ],
      ),
    );
  }

  Widget _buildActivityProgress(String title, Map<String, dynamic> data) {
    final date = DateTime.parse(data['date']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Last played: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        if (title == 'Rhyming Words') ...[
          _buildDifficultyProgressWithActualScore('Easy', data['Easy'], _rhymeScores['easy'] ?? 0),
          _buildDifficultyProgressWithActualScore('Medium', data['Medium'], _rhymeScores['medium'] ?? 0),
          _buildDifficultyProgressWithActualScore('Hard', data['Hard'], _rhymeScores['hard'] ?? 0),
        ] else if (title == 'Word Puzzle') ...[
          _buildDifficultyProgressWithActualScore('Easy', data['Easy'], _wordPuzzleScores['easy'] ?? 0),
          _buildDifficultyProgressWithActualScore('Medium', data['Medium'], _wordPuzzleScores['medium'] ?? 0),
          _buildDifficultyProgressWithActualScore('Hard', data['Hard'], _wordPuzzleScores['hard'] ?? 0),
        ] else ...[
          _buildDifficultyProgress('Easy', data['Easy']),
          _buildDifficultyProgress('Medium', data['Medium']),
          _buildDifficultyProgress('Hard', data['Hard']),
        ],
      ],
    );
  }

  Widget _buildDifficultyProgressWithActualScore(String difficulty, Map<String, dynamic> data, int actualScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              difficulty,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: actualScore / data['total'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(_calculateStatus(actualScore, data['total'])),
              ),
              minHeight: 20,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$actualScore/${data['total']}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _calculateStatus(actualScore, data['total']),
            style: GoogleFonts.poppins(
              color: _getStatusColor(_calculateStatus(actualScore, data['total'])),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateStatus(int score, int total) {
    double percentage = score / total;
    if (percentage < 0.5) return 'Failed';
    if (percentage < 0.75) return 'Good';
    return 'Very Good';
  }

  Widget _buildDifficultyProgress(String difficulty, Map<String, dynamic> data) {
    bool isCompleted = data['score'] >= data['total'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  difficulty,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.black,
                  ),
                ),
                if (isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: data['score'] / data['total'],
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(data['status']),
                  ),
                  minHeight: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
                if (isCompleted)
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${data['score']}/${data['total']}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.green : Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Text(
            data['status'],
            style: GoogleFonts.poppins(
              color: _getStatusColor(data['status']),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'failed':
        return Colors.red;
      case 'good':
        return Colors.green;
      case 'very good':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/background1.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBackToHome,
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // User Info Section
                      _buildUserInfoSection(),
                      SizedBox(height: 20),
                      // Progress Section
                      _buildProgressSection(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
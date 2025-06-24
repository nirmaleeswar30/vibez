// lib/screens/onboarding_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // <-- IMPORT THE NEW PACKAGE
import 'package:vibe_together_app/models/question_model.dart';
import 'package:vibe_together_app/services/onboarding_data.dart';
import 'package:vibe_together_app/widgets/auth_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  // --- CHANGE 1: Use the new AudioPlayer class ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPage = 0;
  final Map<String, int> _vibeScores = {
    'Explorer': 0,
    'Creator': 0,
    'Thinker': 0,
    'Connector': 0,
    'Harmonizer': 0
  };

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
        _playQuestionAudio();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _playQuestionAudio());
  }

  void _playQuestionAudio() async {
    if (_currentPage < onboardingQuestions.length) {
      final question = onboardingQuestions[_currentPage];
      try {
        await _audioPlayer.stop();
        // --- CHANGE 2: Use the new play method with AssetSource ---
        // Note: The audioplayers package doesn't want the "assets/" prefix.
        // It automatically looks in the assets folder.
        final String audioPathWithoutAssets = question.audioPath.replaceFirst('assets/', '');
        await _audioPlayer.play(AssetSource(audioPathWithoutAssets));
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  void _answerQuestion(String vibe) {
    setState(() {
      _vibeScores[vibe] = (_vibeScores[vibe] ?? 0) + 1;
    });

    if (_currentPage < onboardingQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await _audioPlayer.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String primaryVibe = '';
    int maxScore = -1;
    _vibeScores.forEach((vibe, score) {
      if (score > maxScore) {
        maxScore = score;
        primaryVibe = vibe;
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    final currentUserRef = db.collection('users').doc(user.uid);
    batch.set(
        currentUserRef,
        {
          'primaryVibe': primaryVibe,
          'vibeScores': _vibeScores,
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    final matchesQuery = await db
        .collection('users')
        .where('primaryVibe', isEqualTo: primaryVibe)
        .where('uid', isNotEqualTo: user.uid)
        .get();

    if (matchesQuery.docs.isNotEmpty) {
      for (final matchDoc in matchesQuery.docs) {
        final matchedUserId = matchDoc.id;
        final matchedUserData = matchDoc.data();

        final notificationForMatchRef = db
            .collection('users')
            .doc(matchedUserId)
            .collection('notifications')
            .doc(user.uid);
        batch.set(notificationForMatchRef, {
          'matchedUserName': user.displayName,
          'matchedUserVibe': primaryVibe,
          'timestamp': FieldValue.serverTimestamp(),
          'seen': false,
        });

        final notificationForCurrentUserRef = db
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(matchedUserId);
        batch.set(notificationForCurrentUserRef, {
          'matchedUserName': matchedUserData['displayName'],
          'matchedUserVibe': primaryVibe,
          'timestamp': FieldValue.serverTimestamp(),
          'seen': false,
        });
      }
    }

    await batch.commit();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // --- CHANGE 3: Release the player resources ---
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: onboardingQuestions.length,
        itemBuilder: (context, index) {
          final question = onboardingQuestions[index];
          return _buildQuestionPage(question);
        },
      ),
    );
  }

  Widget _buildQuestionPage(Question question) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.hearing, color: Color(0xFFe94560), size: 60),
          const SizedBox(height: 30),
          Text(
            question.text,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 50),
          ...question.answers.map((answer) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(answer.vibe),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(answer.text, textAlign: TextAlign.center),
                ),
              )).toList(),
        ],
      ),
    );
  }
}
// lib/services/onboarding_data.dart
import 'package:vibe_together_app/models/question_model.dart';

final List<Question> onboardingQuestions = [
  Question(
    text: "It's a surprise long weekend! Someone just handed you a plane ticket. No obligations. What's your immediate feeling?",
    audioPath: "assets/audio/q1.mp3",
    answers: [
      Answer(text: "Pure excitement! Where are we going?", vibe: "Explorer"),
      Answer(text: "Ooh, I'll bring my sketchbook. Imagine the inspiration!", vibe: "Creator"),
      Answer(text: "I'd want to know the destination first. Time to research!", vibe: "Thinker"),
      Answer(text: "Awesome! Can I bring my friends?", vibe: "Connector"),
      Answer(text: "Sounds a bit stressful. A cozy weekend at home is better.", vibe: "Harmonizer"),
    ],
  ),
  Question(
    text: "You walk into a party. What's your natural move?",
    audioPath: "assets/audio/q2.mp3",
    answers: [
      Answer(text: "Head straight for the music. A good playlist is everything.", vibe: "Creator"),
      Answer(text: "Scan for the most interesting group and dive in.", vibe: "Connector"),
      Answer(text: "Find a quiet corner to people-watch and observe.", vibe: "Thinker"),
      Answer(text: "Start a conversation about a wild trip I just took.", vibe: "Explorer"),
      Answer(text: "Stick near the door, grab a drink, and ease into it.", vibe: "Harmonizer"),
    ],
  ),
  // ... Add 3 more questions following the same structure
  Question(
    text: "A perfect evening in involves...",
    audioPath: "assets/audio/q3.mp3",
    answers: [
        Answer(text: "Getting lost in a fascinating documentary.", vibe: "Thinker"),
        Answer(text: "Cooking a nice meal and just unwinding.", vibe: "Harmonizer"),
        Answer(text: "Hosting a game night for my closest friends.", vibe: "Connector"),
        Answer(text: "Working on a personal project, like painting or coding.", vibe: "Creator"),
        Answer(text: "Planning my next big adventure.", vibe: "Explorer"),
    ]
  ),
  Question(
    text: "When you face a problem, your first instinct is to...",
    audioPath: "assets/audio/q4.mp3",
    answers: [
        Answer(text: "Break it down logically and analyze every part.", vibe: "Thinker"),
        Answer(text: "Brainstorm a creative, out-of-the-box solution.", vibe: "Creator"),
        Answer(text: "Talk it through with someone I trust.", vibe: "Connector"),
        Answer(text: "Find a way to keep things calm and avoid conflict.", vibe: "Harmonizer"),
        Answer(text: "Jump right in and try something, even if it might fail.", vibe: "Explorer"),
    ]
  ),
  Question(
    text: "Which of these sounds most like you?",
    audioPath: "assets/audio/q5.mp3",
    answers: [
        Answer(text: "I'm always looking for a new experience.", vibe: "Explorer"),
        Answer(text: "I live to create and express myself.", vibe: "Creator"),
        Answer(text: "I thrive on connection and community.", vibe: "Connector"),
        Answer(text: "I value peace and inner balance above all.", vibe: "Harmonizer"),
        Answer(text: "I'm driven by curiosity and the need to understand.", vibe: "Thinker"),
    ]
  ),
];
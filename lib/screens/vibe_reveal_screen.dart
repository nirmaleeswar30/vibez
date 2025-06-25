// lib/screens/vibe_reveal_screen.dart

import 'package:flutter/material.dart';
import 'package:vibe_together_app/widgets/auth_wrapper.dart';

class VibeRevealScreen extends StatelessWidget {
  final String primaryVibe;

  const VibeRevealScreen({super.key, required this.primaryVibe});

  // A helper map to get descriptions for each vibe
  static const Map<String, String> vibeDescriptions = {
    'Explorer': 'You are adventurous and spontaneous, always ready for the next journey!',
    'Creator': 'You are imaginative and artistic, seeing the world through a unique lens.',
    'Thinker': 'You are curious and intellectual, loving deep conversations and new ideas.',
    'Connector': 'You are social and empathetic, thriving on building communities.',
    'Harmonizer': 'You are calm and grounded, valuing peace and creating balance.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'We\'ve found your vibe!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Chip(
                label: Text(
                  primaryVibe,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              const SizedBox(height: 20),
              Text(
                vibeDescriptions[primaryVibe] ?? 'You have a unique and amazing vibe!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("Let's Go!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
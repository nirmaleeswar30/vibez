// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      // The old dark gradient is removed, now it respects the theme
      body: Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Using your actual logo now
            Image.network(
              "https://res.cloudinary.com/dr8g09icb/image/upload/v1750832781/ChatGPT_Image_Jun_25_2025_05_20_20_AM_qzzfl4.png",
              height: 150,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Vibez',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Find your tribe. Share your vibe.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 70),
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Sign in with Google', style: TextStyle(fontSize: 18)),
              onPressed: () async {
                await authService.signInWithGoogle();
              },
              // This button will now use the style from our global ElevatedButtonTheme
            ),
            const SizedBox(height: 20),
            Text(
              'More sign-in options coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
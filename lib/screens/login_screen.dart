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
      body: Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
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
            const Icon(
              Icons.vibration,
              size: 100,
              color: Color(0xFFe94560),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Vibe Together',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Find your tribe. Share your vibe.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 70),
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Sign in with Google', style: TextStyle(fontSize: 18)),
              onPressed: () async {
                await authService.signInWithGoogle();
                // AuthWrapper will handle navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'More sign-in options coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/widgets/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/screens/home_screen.dart';
import 'package:vibe_together_app/screens/login_screen.dart';
import 'package:vibe_together_app/screens/onboarding_screen.dart';
import 'package:vibe_together_app/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // User is logged in, check if they've completed onboarding
          return FutureBuilder<bool>(
            future: authService.hasCompletedOnboarding(snapshot.data!.uid),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (onboardingSnapshot.data == true) {
                // Onboarding complete, show home screen
                return const HomeScreen();
              } else {
                // Onboarding not complete, show onboarding screen
                return OnboardingScreen();
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
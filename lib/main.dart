// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/firebase_options.dart';
import 'package:vibe_together_app/providers/user_provider.dart';
import 'package:vibe_together_app/services/auth_service.dart';
import 'package:vibe_together_app/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- THEME DEFINITION IS HERE ---
    const primaryPurple = Color(0xFF6A1B9A); // A deep purple from the logo
    const accentPurple = Color(0xFF8E24AA); // A slightly brighter accent

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Vibez',
        theme: ThemeData(
          // --- GLOBAL THEME SETTINGS ---
          brightness: Brightness.light,
          primaryColor: primaryPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryPurple,
            primary: primaryPurple,
            secondary: accentPurple,
            background: const Color(0xFFFAFAFA), // Off-white background
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          cardColor: Colors.white,

          // --- WIDGET-SPECIFIC THEMES ---
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black, // For title and icons
            elevation: 1.0,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Colors.black87),
            titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: primaryPurple.withOpacity(0.1),
            labelStyle: const TextStyle(color: primaryPurple),
            side: BorderSide.none,
          ),
           bottomAppBarTheme: const BottomAppBarTheme(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
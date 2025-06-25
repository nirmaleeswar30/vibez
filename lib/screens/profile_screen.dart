// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/providers/user_provider.dart';
import 'package:vibe_together_app/screens/edit_profile_screen.dart';
import 'package:vibe_together_app/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use watch:true here so the UI updates when profile is edited
    final AppUser? user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          // --- LAYOUT FIX IS HERE ---
          // Using Center widget to vertically and horizontally center the Column
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Vertically centers content
                  crossAxisAlignment: CrossAxisAlignment.center, // Horizontally centers content
                  children: [
                    const Spacer(), // Pushes content down a bit from the app bar
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 24),
                    if (user.primaryVibe != null)
                      Chip(
                        label: Text(
                          user.primaryVibe!,
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    const Spacer(), // Takes up the remaining space in the middle
                    ElevatedButton(
                      onPressed: () async {
                        await Provider.of<AuthService>(context, listen: false).signOut();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Log Out", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 60), // Space at the bottom
                  ],
                ),
              ),
            ),
    );
  }
}
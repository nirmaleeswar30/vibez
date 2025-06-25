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
          : Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  const SizedBox(height: 10),
                  Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await Provider.of<AuthService>(context, listen: false).signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                    child: const Text("Log Out"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
// lib/screens/user_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/screens/chat_screen.dart';
import 'package:vibe_together_app/services/chat_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        setState(() {
          _user = AppUser.fromFirestore(doc);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.displayName ?? "User Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text("User not found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_user!.photoUrl),
                        backgroundColor: Colors.grey.shade800,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _user!.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Chip(
                          label: Text(
                            _user!.primaryVibe ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFFe94560),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      const Spacer(),
                      _buildChatButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChatButton() {
    // This is a special case to prevent users from trying to chat with themselves.
    if (widget.userId == _currentUserId) {
      return const SizedBox.shrink();
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _chatService.getChatStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Case 1: No chat document exists. Show "Send Request".
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ElevatedButton.icon(
            onPressed: () {
              _chatService.sendChatRequest(widget.userId);
            },
            icon: const Icon(Icons.send_and_archive),
            label: const Text("Send Vibe Request"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          );
        }

        final chatData = snapshot.data!.data() as Map<String, dynamic>;
        final status = chatData['status'];
        final requestedBy = chatData['requestedBy'];
        final chatId = snapshot.data!.id;

        // Case 2: Status is 'pending'.
        if (status == 'pending') {
          if (requestedBy == _currentUserId) {
            // I sent the request. Show "Request Sent".
            return ElevatedButton.icon(
              onPressed: null, // Disabled
              icon: const Icon(Icons.hourglass_top),
              label: const Text("Request Sent"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            );
          } else {
            // They sent the request. Show "Accept".
            return ElevatedButton.icon(
              onPressed: () {
                _chatService.acceptChatRequest(chatId);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Accept Vibe"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            );
          }
        }

        // Case 3: Status is 'accepted'.
        if (status == 'accepted') {
          return ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatId,
                    otherUserName: _user!.displayName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text("Message"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          );
        }

        // --- NEW CASE ---
        // Case 4: Status is 'declined'.
        if (status == 'declined') {
          return ElevatedButton.icon(
            onPressed: null, // Disabled
            icon: const Icon(Icons.do_not_disturb_on),
            label: const Text("Vibe Request Declined"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white54,
            ),
          );
        }

        // Default/fallback case, should not be reached.
        return const SizedBox.shrink();
      },
    );
  }
}
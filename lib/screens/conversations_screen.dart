// lib/screens/conversations_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/screens/chat_screen.dart';
import 'package:vibe_together_app/services/chat_service.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController is a convenient way to manage tabs.
    return DefaultTabController(
      length: 2, // We have two tabs: Chats and Requests
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Conversations"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble), text: "Chats"),
              Tab(icon: Icon(Icons.person_add), text: "Requests"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Each tab's content is built in a separate, clean widget.
            _ChatsList(),
            _RequestsList(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET FOR THE "CHATS" TAB ---
class _ChatsList extends StatelessWidget {
  const _ChatsList();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final ChatService chatService = ChatService();

    return StreamBuilder<QuerySnapshot>(
      // This query finds all chats that are 'accepted' and include the current user.
      // It orders them by the last message's timestamp to show the most recent first.
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .orderBy('lastMessage.timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("You have no active chats yet.",
                  style: TextStyle(color: Colors.white54)));
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatData = chatDocs[index].data() as Map<String, dynamic>;
            final chatId = chatDocs[index].id;
            
            // Find the other user's ID from the 'users' array.
            final List<String> userIds = List<String>.from(chatData['users']);
            final String otherUserId =
                userIds.firstWhere((id) => id != currentUserId);

            // The last message data for the subtitle.
            final lastMessage = chatData['lastMessage'] as Map<String, dynamic>?;

            // We use a FutureBuilder to fetch the other user's details (name, photo)
            // This is a common and efficient pattern for list items.
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text("Loading..."));
                }
                final otherUser = AppUser.fromFirestore(userSnapshot.data!);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(otherUser.photoUrl),
                  ),
                  title: Text(otherUser.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    lastMessage != null ? lastMessage['text'] : "Chat started",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserName: otherUser.displayName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}


// --- WIDGET FOR THE "REQUESTS" TAB ---
class _RequestsList extends StatelessWidget {
  const _RequestsList();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final ChatService chatService = ChatService();

    return StreamBuilder<QuerySnapshot>(
      // This query finds all 'pending' chats where the current user is a participant,
      // but DID NOT send the request. This is how we find requests sent TO us.
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .where('status', isEqualTo: 'pending')
          .where('requestedBy', isNotEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("You have no pending vibe requests.",
                  style: TextStyle(color: Colors.white54)));
        }

        final requestDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requestDocs.length,
          itemBuilder: (context, index) {
            final requestData = requestDocs[index].data() as Map<String, dynamic>;
            final chatId = requestDocs[index].id;
            final String requesterId = requestData['requestedBy'];

            // Fetch the requester's user details to display them.
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(requesterId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text("Loading..."));
                }
                final requester = AppUser.fromFirestore(userSnapshot.data!);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(requester.photoUrl),
                    ),
                    title: Text(requester.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Sent you a vibe request!"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () {
                            chatService.acceptChatRequest(chatId);
                          },
                          tooltip: "Accept",
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            chatService.declineChatRequest(chatId);
                          },
                          tooltip: "Decline",
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
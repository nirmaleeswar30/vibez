// lib/screens/notifications_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/screens/user_profile_screen.dart'; // <-- ADD THIS

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _markAllNotificationsAsSeen();
  }

  Future<void> _markAllNotificationsAsSeen() async {
    final db = FirebaseFirestore.instance;
    final notificationsRef = db
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .where('seen', isEqualTo: false);

    final notificationsToUpdate = await notificationsRef.get();

    if (notificationsToUpdate.docs.isEmpty) {
      return;
    }

    final batch = db.batch();
    for (final doc in notificationsToUpdate.docs) {
      batch.update(doc.reference, {'seen': true});
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Vibe Matches'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No new vibe matches yet.\nCome back soon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
            );
          }

          final notificationDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notificationDocs.length,
            itemBuilder: (context, index) {
              final notificationData =
                  notificationDocs[index].data() as Map<String, dynamic>;
              final matchedUserId = notificationDocs[index].id;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFFe94560)),
                  title: Text(
                    '${notificationData['matchedUserName'] ?? 'A new user'} has joined your tribe!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      'They are a ${notificationData['matchedUserVibe'] ?? 'Viber'} too.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // --- THE MAIN CHANGE IS HERE ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileScreen(userId: matchedUserId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
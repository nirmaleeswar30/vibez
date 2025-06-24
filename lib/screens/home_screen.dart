// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/providers/user_provider.dart';
import 'package:vibe_together_app/screens/conversations_screen.dart';
import 'package:vibe_together_app/screens/notifications_screen.dart';
import 'package:vibe_together_app/screens/user_profile_screen.dart';
import 'package:vibe_together_app/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the user's own data once when the screen loads.
    Provider.of<UserProvider>(context, listen: false).fetchUser();
  }

  /// This function runs whenever the list of matches updates.
  /// It checks for new matches that we haven't created a notification for yet.
  Future<void> _handleNewMatches(
      List<DocumentSnapshot> matches, String currentUserId) async {
    if (matches.isEmpty) return;

    final db = FirebaseFirestore.instance;
    final notificationsRef =
        db.collection('users').doc(currentUserId).collection('notifications');

    // Get the IDs of notifications we've already created.
    final existingNotificationsSnapshot = await notificationsRef.get();
    final existingNotificationIds =
        existingNotificationsSnapshot.docs.map((doc) => doc.id).toSet();

    // Find the new matches by filtering out ones we already have notifications for.
    final newMatches = matches
        .where((match) => !existingNotificationIds.contains(match.id))
        .toList();

    if (newMatches.isEmpty) return;

    // Use a batch to create all new notifications at once for efficiency.
    final batch = db.batch();
    for (final matchDoc in newMatches) {
      final matchData = matchDoc.data() as Map<String, dynamic>;
      final notificationDocRef = notificationsRef.doc(matchDoc.id);
      batch.set(notificationDocRef, {
        'matchedUserName': matchData['displayName'],
        'matchedUserVibe': matchData['primaryVibe'],
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });
    }

    await batch.commit();
    print("Created ${newMatches.length} new match notifications.");
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final AppUser? currentUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Vibe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined),
            tooltip: "My Chats & Requests",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConversationsScreen()),
              );
            },
          ),
          if (currentUser != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('notifications')
                  .where('seen', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsScreen())),
                  );
                }
                final unseenCount = snapshot.data!.docs.length;
                return Badge(
                  label: Text(unseenCount.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsScreen())),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authService.signOut(),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- TOP SECTION: CURRENT USER INFO ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(currentUser.photoUrl),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome, ${currentUser.displayName}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Chip(
                        label: Text(
                          currentUser.primaryVibe ?? 'Calculating...',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFe94560),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      Text(
                        'Your Vibe Tribe ✨',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ],
                  ),
                ),

                // --- BOTTOM SECTION: LIVE LIST OF MATCHES ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // This stream gets all other users with the same vibe.
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('primaryVibe', isEqualTo: currentUser.primaryVibe)
                        .where('uid', isNotEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Finding your tribe...\nNo other matches yet!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white54),
                          ),
                        );
                      }

                      final matchDocs = snapshot.data!.docs;
                      
                      // This is where the magic happens: every time the list
                      // updates, we check if there are new members to notify about.
                      _handleNewMatches(matchDocs, currentUser.uid);

                      return ListView.builder(
                        itemCount: matchDocs.length,
                        itemBuilder: (context, index) {
                          final matchData =
                              AppUser.fromFirestore(matchDocs[index]);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(matchData.photoUrl),
                              ),
                              title: Text(matchData.displayName, style: const TextStyle(fontWeight: FontWeight.bold),),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfileScreen(userId: matchData.uid),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
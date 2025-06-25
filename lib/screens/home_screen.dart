// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibe_together_app/models/post_model.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/models/vibe_event_model.dart';
import 'package:vibe_together_app/providers/user_provider.dart';
import 'package:vibe_together_app/screens/notifications_screen.dart'; // <-- IMPORT
import 'package:vibe_together_app/screens/profile_screen.dart';
import 'package:vibe_together_app/widgets/post_card_widget.dart';
import 'package:vibe_together_app/widgets/vibe_event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUser();
  }

  Stream<List<dynamic>> _getCombinedFeed() {
    final postsStream = FirebaseFirestore.instance.collection('posts').where('groupId', isNull: true).snapshots();
    final vibesStream = FirebaseFirestore.instance.collection('vibes').snapshots();
    return Rx.combineLatest2(postsStream, vibesStream, (QuerySnapshot posts, QuerySnapshot vibes) {
      final List<dynamic> combinedList = [];
      combinedList.addAll(posts.docs.map((doc) => Post.fromFirestore(doc)));
      combinedList.addAll(vibes.docs.map((doc) => VibeEvent.fromFirestore(doc)));
      combinedList.sort((a, b) {
        Timestamp timeA = a is Post ? a.timestamp : (a as VibeEvent).eventDate;
        Timestamp timeB = b is Post ? b.timestamp : (b as VibeEvent).eventDate;
        return timeB.compareTo(timeA);
      });
      return combinedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibez'),
        elevation: 1,
        actions: [
          // --- NOTIFICATION ICON IS HERE ---
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
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                  );
                }
                final unseenCount = snapshot.data!.docs.length;
                return Badge(
                  label: Text(unseenCount.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<dynamic>>(
              stream: _getCombinedFeed(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Be the first to create a post or vibe!"));
                final feedItems = snapshot.data!;
                return ListView.builder(
                  itemCount: feedItems.length,
                  itemBuilder: (context, index) {
                    final item = feedItems[index];
                    if (item is Post) return PostCard(post: item);
                    if (item is VibeEvent) return VibeEventCard(event: item);
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
    );
  }
}
// lib/screens/search_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/group_model.dart'; // <-- IMPORT GROUP MODEL
import 'package:vibe_together_app/models/post_model.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/models/vibe_event_model.dart';
import 'package:vibe_together_app/screens/group_detail_screen.dart'; // <-- IMPORT GROUP DETAIL SCREEN
import 'package:vibe_together_app/screens/user_profile_screen.dart';
import 'package:vibe_together_app/widgets/group_card_widget.dart'; // <-- IMPORT GROUP CARD
import 'package:vibe_together_app/widgets/post_card_widget.dart';
import 'package:vibe_together_app/widgets/vibe_event_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search Users, Posts, Vibes...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Posts"),
              Tab(text: "Users"),
              Tab(text: "Vibes"),
              Tab(text: "Groups"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPostsFeed(),
            _buildUsersList(_searchQuery),
            _buildVibesFeed(),
            _buildGroupsList(), // <-- USE THE NEW METHOD HERE
          ],
        ),
      ),
    );
  }

  Widget _buildPostsFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();
        return ListView.builder(itemCount: posts.length, itemBuilder: (context, index) => PostCard(post: posts[index]));
      },
    );
  }

  Widget _buildUsersList(String query) {
    Stream<QuerySnapshot> stream;
    if (query.isEmpty) {
      stream = FirebaseFirestore.instance.collection('users').snapshots();
    } else {
      stream = FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No users found."));
        
        final users = snapshot.data!.docs.map((doc) => AppUser.fromFirestore(doc)).toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
              title: Text(user.displayName),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.uid)));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildVibesFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vibes').orderBy('eventDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No vibes happening right now."));
        }

        final vibes = snapshot.data!.docs.map((doc) => VibeEvent.fromFirestore(doc)).toList();

        return ListView.builder(
          itemCount: vibes.length,
          itemBuilder: (context, index) {
            return VibeEventCard(event: vibes[index]);
          },
        );
      },
    );
  }

  // --- NEW WIDGET TO LIST ALL PUBLIC GROUPS ---
  Widget _buildGroupsList() {
    return StreamBuilder<QuerySnapshot>(
      // This is the same query from our main GroupsScreen.
      // Remember to create the Firestore Index for this query if you haven't already.
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData == false || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No public groups available."));
        }
        
        // This handles potential errors from the stream (e.g., missing index)
        if (snapshot.hasError) {
          print("Error fetching groups: ${snapshot.error}");
          return const Center(child: Text("Error loading groups. Check console for details."));
        }

        final groups = snapshot.data!.docs.map((doc) => Group.fromFirestore(doc)).toList();

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return GroupCard(
              group: group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupDetailScreen(groupId: group.id)),
                );
              },
            );
          },
        );

      },
    );
  }
}
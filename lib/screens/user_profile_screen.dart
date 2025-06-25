// lib/screens/user_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/post_model.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/screens/chat_screen.dart';
import 'package:vibe_together_app/services/chat_service.dart';
import 'package:vibe_together_app/widgets/post_card_widget.dart';

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
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        setState(() { _user = AppUser.fromFirestore(doc); _isLoading = false; });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
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
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(),
                      ),
                    ];
                  },
                  body: _buildUserContent(),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 60, backgroundImage: NetworkImage(_user!.photoUrl)),
          const SizedBox(height: 20),
          Text(_user!.displayName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Chip(
            label: Text(_user!.primaryVibe ?? 'N/A'),
            backgroundColor: const Color(0xFFe94560),
          ),
          const SizedBox(height: 20),
          _buildChatButton(),
          const SizedBox(height: 20),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildUserContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Posts"),
              Tab(text: "Vibes"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUserPosts(),
                const Center(child: Text("User's created vibes coming soon!")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No posts yet."));
        final posts = snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }

  Widget _buildChatButton() {
    if (widget.userId == _currentUserId) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot>(
      stream: _chatService.getChatStream(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        if (!snapshot.data!.exists) {
          return ElevatedButton.icon(onPressed: () => _chatService.sendChatRequest(widget.userId), icon: const Icon(Icons.send_and_archive), label: const Text("Send Vibe Request"));
        }

        final chatData = snapshot.data!.data() as Map<String, dynamic>;
        final status = chatData['status'];
        final requestedBy = chatData['requestedBy'];
        final chatId = snapshot.data!.id;

        if (status == 'pending') {
          return requestedBy == _currentUserId
              ? ElevatedButton.icon(onPressed: null, icon: const Icon(Icons.hourglass_top), label: const Text("Request Sent"))
              : ElevatedButton.icon(onPressed: () => _chatService.acceptChatRequest(chatId), icon: const Icon(Icons.check_circle_outline), label: const Text("Accept Vibe"));
        }

        if (status == 'accepted') {
          return ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, otherUserName: _user!.displayName))), icon: const Icon(Icons.chat), label: const Text("Message"));
        }
        
        if (status == 'declined') {
          return ElevatedButton.icon(onPressed: null, icon: const Icon(Icons.do_not_disturb_on), label: const Text("Vibe Request Declined"));
        }

        return const SizedBox.shrink();
      },
    );
  }
}
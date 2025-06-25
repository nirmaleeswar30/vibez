// lib/screens/group_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/group_model.dart';
import 'package:vibe_together_app/models/post_model.dart';
import 'package:vibe_together_app/screens/create_post_screen.dart';
import 'package:vibe_together_app/services/group_service.dart';
import 'package:vibe_together_app/widgets/post_card_widget.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  final GroupService _groupService = GroupService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        final group = Group.fromFirestore(snapshot.data!);
        final bool isMember = _currentUserId != null && group.members.contains(_currentUserId);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(group.name, style: const TextStyle(fontSize: 16.0)),
                    background: Image.network(
                      group.groupPhotoUrl,
                      fit: BoxFit.cover,
                      color: Colors.black45,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  actions: [
                    if(isMember) // Only show create post button if user is a member
                      IconButton(
                        icon: const Icon(Icons.add_comment_outlined),
                        tooltip: 'Create Post in Group',
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreatePostScreen(groupId: group.id, groupName: group.name,)),
                          );
                        },
                      ),
                  ],
                ),
              ];
            },
            body: _buildGroupContent(group, isMember, context),
          ),
        );
      },
    );
  }

  Widget _buildGroupContent(Group group, bool isMember, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.description),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${group.members.length} members'),
                  ElevatedButton(
                    onPressed: () => _groupService.toggleJoinGroup(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMember ? Colors.grey.shade700 : Theme.of(context).primaryColor,
                    ),
                    child: Text(isMember ? 'Leave Group' : 'Join Group'),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text("Group Feed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        Expanded(
          child: _buildGroupPostsFeed(group.id),
        ),
      ],
    );
  }

  Widget _buildGroupPostsFeed(String groupId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('groupId', isEqualTo: groupId) // The key query
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No posts in this group yet."));
        
        final posts = snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();
        
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }
}
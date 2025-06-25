// lib/screens/groups_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/group_model.dart';
import 'package:vibe_together_app/screens/create_group_screen.dart';
import 'package:vibe_together_app/screens/group_detail_screen.dart'; // <-- IMPORT
import 'package:vibe_together_app/widgets/group_card_widget.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Create Group",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('isPublic', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No public groups found. Create one!"));
          }

          final groups = snapshot.data!.docs.map((doc) => Group.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return GroupCard(
                group: group,
                onTap: () {
                  // --- THIS IS THE CHANGE ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(groupId: group.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
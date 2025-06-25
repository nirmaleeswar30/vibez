// lib/screens/vibe_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/user_model.dart';
import 'package:vibe_together_app/models/vibe_event_model.dart';
import 'package:vibe_together_app/screens/vibe_comment_screen.dart'; // <-- IMPORT
import 'package:vibe_together_app/widgets/vibe_event_card.dart';

class VibeDetailScreen extends StatelessWidget {
  final String vibeId;
  const VibeDetailScreen({super.key, required this.vibeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vibe Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('vibes').doc(vibeId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final event = VibeEvent.fromFirestore(snapshot.data!);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl != null) Image.network(event.imageUrl!),
                VibeEventCard(event: event),
                // --- NEW COMMENT SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextButton.icon(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => VibeCommentScreen(vibeId: event.id)));
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text("View all ${event.commentCount} comments"),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Attendees", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _buildAttendeesList(event.attendees),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendeesList(List<String> attendeeIds) {
    if (attendeeIds.isEmpty) return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text("No one has joined yet."),
    );
    return ListView.builder(
      shrinkWrap: true, // Important for ListView inside a Column
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendeeIds.length,
      itemBuilder: (context, index) {
        final userId = attendeeIds[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const ListTile(title: Text("Loading..."));
            final user = AppUser.fromFirestore(snapshot.data!);
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
              title: Text(user.displayName),
            );
          },
        );
      },
    );
  }
}
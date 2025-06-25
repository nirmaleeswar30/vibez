// lib/screens/vibe_comment_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class VibeCommentScreen extends StatefulWidget {
  final String vibeId;
  const VibeCommentScreen({super.key, required this.vibeId});

  @override
  State<VibeCommentScreen> createState() => _VibeCommentScreenState();
}

class _VibeCommentScreenState extends State<VibeCommentScreen> {
  final _commentController = TextEditingController();

  Future<void> _postComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.trim().isEmpty) return;

    final commentText = _commentController.text.trim();
    _commentController.clear(); // Clear the field immediately

    final vibeRef = FirebaseFirestore.instance.collection('vibes').doc(widget.vibeId);

    // Add the comment to the subcollection
    await vibeRef.collection('comments').add({
      'text': commentText,
      'authorId': user.uid,
      'authorName': user.displayName,
      'authorPhotoUrl': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Increment the comment count on the main vibe document using an atomic transaction
    await vibeRef.update({'commentCount': FieldValue.increment(1)});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vibe Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vibes')
                  .doc(widget.vibeId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No comments yet. Be the first!"));

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data() as Map<String, dynamic>;
                    final timestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(comment['authorPhotoUrl'])),
                      title: Text(comment['authorName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(comment['text']),
                      trailing: Text(timeago.format(timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  },
                );
              },
            ),
          ),
          // Input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send, color: Theme.of(context).primaryColor), onPressed: _postComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
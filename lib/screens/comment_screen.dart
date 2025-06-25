// lib/screens/comment_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();

  Future<void> _postComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.trim().isEmpty) return;

    final commentText = _commentController.text.trim();
    _commentController.clear();

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    // Add the comment to the subcollection
    await postRef.collection('comments').add({
      'text': commentText,
      'authorId': user.uid,
      'authorName': user.displayName,
      'authorPhotoUrl': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Increment the comment count on the main post document
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Comments")),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final comments = snapshot.data!.docs;
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index].data() as Map<String, dynamic>;
                  final timestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(comment['authorPhotoUrl'])),
                    title: Text(comment['authorName']),
                    subtitle: Text(comment['text']),
                    trailing: Text(timeago.format(timestamp), style: const TextStyle(fontSize: 10)),
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
                  decoration: const InputDecoration(hintText: 'Add a comment...'),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _postComment),
            ],
          ),
        ),
      ],
    ),
  );
}
}
// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final String text;
  final String? imageUrl;
  final String? groupId; // <-- NEW FIELD
  final Timestamp timestamp;
  final List<String> likes;
  final int commentCount;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.text,
    this.imageUrl,
    this.groupId, // <-- NEW FIELD
    required this.timestamp,
    required this.likes,
    required this.commentCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown User',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      groupId: data['groupId'], // <-- NEW FIELD
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }
}
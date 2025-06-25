// lib/services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    if (_currentUserId == null) return;

    final postRef = _db.collection('posts').doc(postId);

    if (currentLikes.contains(_currentUserId)) {
      // User has already liked the post, so unlike it
      await postRef.update({
        'likes': FieldValue.arrayRemove([_currentUserId])
      });
    } else {
      // User has not liked the post, so like it
      await postRef.update({
        'likes': FieldValue.arrayUnion([_currentUserId])
      });
    }
  }
}
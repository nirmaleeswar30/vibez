// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> updateUserProfile({
    required String newName,
    String? newPhotoUrl,
  }) async {
    if (_currentUserId == null) return;

    final batch = _db.batch();

    // 1. Update the main user document
    final userRef = _db.collection('users').doc(_currentUserId);
    Map<String, dynamic> updateData = {'displayName': newName};
    if (newPhotoUrl != null) {
      updateData['photoUrl'] = newPhotoUrl;
    }
    batch.update(userRef, updateData);

    // 2. Find all posts by this user and update them
    final postsQuery = await _db
        .collection('posts')
        .where('authorId', isEqualTo: _currentUserId)
        .get();

    for (final doc in postsQuery.docs) {
      Map<String, dynamic> postUpdateData = {'authorName': newName};
       if (newPhotoUrl != null) {
        postUpdateData['authorPhotoUrl'] = newPhotoUrl;
      }
      batch.update(doc.reference, postUpdateData);
    }
    
    // You would do the same for comments, group memberships, etc.
    // For now, we'll stick to users and posts.

    // 3. Commit all changes at once
    await batch.commit();
  }
}
// lib/services/group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_together_app/models/group_model.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> toggleJoinGroup(Group group) async {
    if (_currentUserId == null) return;

    final groupRef = _db.collection('groups').doc(group.id);

    if (group.members.contains(_currentUserId)) {
      // User is a member, so leave the group.
      await groupRef.update({
        'members': FieldValue.arrayRemove([_currentUserId])
      });
    } else {
      // User is not a member, so join the group.
      // We assume public groups can be joined freely.
      // Private groups would require a request/invite system.
      if (group.isPublic) {
        await groupRef.update({
          'members': FieldValue.arrayUnion([_currentUserId])
        });
      } else {
        // Handle logic for private groups if needed (e.g., send join request)
        print("This is a private group. Request functionality not implemented yet.");
      }
    }
  }
}
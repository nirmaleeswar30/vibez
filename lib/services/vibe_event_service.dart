// lib/services/vibe_event_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_together_app/models/vibe_event_model.dart'; // <-- THIS IS THE FIX

class VibeEventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> toggleJoinVibe(VibeEvent event) async {
    if (_currentUserId == null) return;

    final vibeRef = _db.collection('vibes').doc(event.id);

    if (event.attendees.contains(_currentUserId)) {
      // User has already joined, so leave.
      await vibeRef.update({
        'attendees': FieldValue.arrayRemove([_currentUserId])
      });
    } else {
      // User has not joined, so join if there is space.
      if (event.attendees.length < event.maxAttendees) {
        await vibeRef.update({
          'attendees': FieldValue.arrayUnion([_currentUserId])
        });
      } else {
        // Optional: Handle the case where the event is full.
        // You could show a SnackBar or a dialog.
        print("Cannot join, vibe is full.");
      }
    }
  }
}
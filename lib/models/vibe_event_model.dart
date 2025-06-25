// lib/models/vibe_event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VibeEvent {
  final String id;
  final String title;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl;
  final String? imageUrl;
  final Timestamp eventDate;
  final String location;
  final int maxAttendees;
  final List<String> attendees;
  final int commentCount; // <-- NEW FIELD

  VibeEvent({
    required this.id,
    required this.title,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhotoUrl,
    this.imageUrl,
    required this.eventDate,
    required this.location,
    required this.maxAttendees,
    required this.attendees,
    required this.commentCount, // <-- NEW FIELD
  });

  factory VibeEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VibeEvent(
      id: doc.id,
      title: data['title'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhotoUrl: data['creatorPhotoUrl'] ?? '',
      imageUrl: data['imageUrl'],
      eventDate: data['eventDate'] ?? Timestamp.now(),
      location: data['location'] ?? 'Venue not yet decided',
      maxAttendees: data['maxAttendees'] ?? 2,
      attendees: List<String>.from(data['attendees'] ?? []),
      commentCount: data['commentCount'] ?? 0, // <-- NEW FIELD
    );
  }
}
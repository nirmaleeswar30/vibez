// lib/models/vibe_event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VibeEvent {
  final String id;
  final String title;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl;
  final Timestamp eventDate;
  final String location;
  final int maxAttendees;
  final List<String> attendees; // List of user UIDs

  VibeEvent({
    required this.id,
    required this.title,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhotoUrl,
    required this.eventDate,
    required this.location,
    required this.maxAttendees,
    required this.attendees,
  });

  factory VibeEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VibeEvent(
      id: doc.id,
      title: data['title'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPhotoUrl: data['creatorPhotoUrl'] ?? '',
      eventDate: data['eventDate'] ?? Timestamp.now(),
      location: data['location'] ?? 'Venue not yet decided',
      maxAttendees: data['maxAttendees'] ?? 2,
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }
}
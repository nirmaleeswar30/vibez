// lib/widgets/vibe_event_card.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_together_app/models/vibe_event_model.dart';
import 'package:vibe_together_app/screens/vibe_detail_screen.dart'; // <-- IMPORT
import 'package:vibe_together_app/services/vibe_event_service.dart';

class VibeEventCard extends StatelessWidget {
  final VibeEvent event;
  final VibeEventService _vibeEventService = VibeEventService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  VibeEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final bool isJoined = currentUserId != null && event.attendees.contains(currentUserId);
    final bool isFull = event.attendees.length >= event.maxAttendees;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // --- WRAP WITH INKWELL ---
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VibeDetailScreen(vibeId: event.id)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(event.imageUrl != null)
              Image.network(event.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [ const Icon(Icons.group_outlined, size: 16), const SizedBox(width: 4), Text('${event.attendees.length} / ${event.maxAttendees} Joined'), const Spacer(), Text("by ${event.creatorName}") ]),
                  const SizedBox(height: 8),
                  Row(children: [ const Icon(Icons.calendar_today_outlined, size: 16), const SizedBox(width: 4), Text(DateFormat('dd MMM, EEE').format(event.eventDate.toDate())) ]),
                  const SizedBox(height: 8),
                  Row(children: [ const Icon(Icons.location_on_outlined, size: 16), const SizedBox(width: 4), Text(event.location) ]),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: (isJoined || !isFull) ? () => _vibeEventService.toggleJoinVibe(event) : null,
                      style: ElevatedButton.styleFrom(backgroundColor: isJoined ? Colors.green : Theme.of(context).primaryColor),
                      child: Text(isJoined ? 'Joined' : (isFull ? 'Full' : 'Join')),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
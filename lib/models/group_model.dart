// lib/models/group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String groupPhotoUrl;
  final String creatorId;
  final List<String> members;
  final bool isPublic;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.groupPhotoUrl,
    required this.creatorId,
    required this.members,
    required this.isPublic,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      groupPhotoUrl: data['groupPhotoUrl'] ?? 'https://i.imgur.com/sRg1g4D.png', // A default image
      creatorId: data['creatorId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      isPublic: data['isPublic'] ?? true,
    );
  }
}
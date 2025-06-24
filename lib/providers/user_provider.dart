// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_together_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? get user => _user;

  Future<void> fetchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = AppUser.fromFirestore(doc);
        notifyListeners();
      }
    }
  }
}
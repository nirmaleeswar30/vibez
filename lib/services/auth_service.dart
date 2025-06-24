// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
 
  // Stream to listen for authentication changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Create user document if it's a new user
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _createUserDocument(user);
        }
        // REMOVED: FCM Token update is no longer needed
        // await _updateFcmToken(user.uid);
      }
      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Create a new user document in Firestore
  Future<void> _createUserDocument(User user) {
    return _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Viber',
      'photoUrl': user.photoURL ?? 'default_photo_url',
      'createdAt': Timestamp.now(),
      'primaryVibe': null, // Vibe is set after onboarding
      'vibeScores': {},
      // No fcmToken needed here
    });
  }

  // REMOVED: The _updateFcmToken method is no longer needed.

  // Check if user has completed onboarding (i.e., has a primaryVibe)
  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['primaryVibe'] != null;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
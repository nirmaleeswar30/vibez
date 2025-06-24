// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- HELPER METHOD (no change) ---
  String getChatId(String otherUserId) {
    final currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    return ids.join('_');
  }

  // --- STREAMS (no change) ---
  Stream<DocumentSnapshot> getChatStream(String otherUserId) {
    final chatId = getChatId(otherUserId);
    return _db.collection('chats').doc(chatId).snapshots();
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- ACTIONS (no change) ---
  Future<void> sendChatRequest(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(otherUserId);
    final chatDocRef = _db.collection('chats').doc(chatId);
    await chatDocRef.set({
      'users': [currentUserId, otherUserId],
      'status': 'pending',
      'requestedBy': currentUserId,
      'lastMessage': null,
    });
  }

  Future<void> acceptChatRequest(String chatId) async {
    await _db.collection('chats').doc(chatId).update({'status': 'accepted'});
  }

  // --- NEW METHOD ---
  Future<void> declineChatRequest(String chatId) async {
    await _db.collection('chats').doc(chatId).update({'status': 'declined'});
  }

  // --- SEND MESSAGE (no change) ---
  Future<void> sendMessage(String chatId, String text) async {
    final currentUserId = _auth.currentUser!.uid;
    final message = {
      'senderId': currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
    await _db.collection('chats').doc(chatId).update({'lastMessage': message});
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // -------- Conversations --------

  /// Fetches all conversations for the current user in real-time
  Stream<List<ConversationModel>> getConversations() {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('conversations')
        .where('participantIds', arrayContains: currentUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ConversationModel.fromMap(data, doc.id, currentUid: currentUid);
      }).toList();
    });
  }

  /// Gets or creates a conversation between two users
  Future<String> getOrCreateConversation(String otherUid) async {
    // Search for existing conversation
    final existing = await _db
        .collection('conversations')
        .where('participantIds', arrayContains: currentUid)
        .get();

    for (final doc in existing.docs) {
      final ids = List<String>.from(doc['participantIds']);
      if (ids.contains(otherUid) && ids.length == 2) {
        return doc.id;
      }
    }

    // If not found, create it
    final meDoc = await _db.collection('users').doc(currentUid).get();
    final otherDoc = await _db.collection('users').doc(otherUid).get();

    final ref = _db.collection('conversations').doc();
    await ref.set({
      'participantIds': [currentUid, otherUid],
      'participants': {
        currentUid: meDoc.data(),
        otherUid: otherDoc.data(),
      },
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
      'unreadCount': {currentUid: 0, otherUid: 0},
    });
    return ref.id;
  }

  // -------- Messages --------
  Future<void> markAsRead(String conversationId) async {
    await _db.collection('conversations').doc(conversationId).update({
      'unreadCount.$currentUid': 0,
    });
  }

  Future<void> setTyping(String conversationId, bool isTyping) async {
    await _db
        .collection('conversations')
        .doc(conversationId)
        .update({'typing.$currentUid': isTyping});
  }

  Stream<bool> getTypingStream(String conversationId, String otherUid) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((doc) => doc.data()?['typing']?[otherUid] ?? false);
  }
  /// Stream messages for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: false)
        .map((snap) =>
        snap.docs.map((d) => MessageModel.fromMap(d.data(), d.id)).toList());
  }

  /// Sends a message
  Future<void> sendMessage(String conversationId, String otherUid, String text) async {
    if (text.trim().isEmpty) return;

    final batch = _db.batch();
    final msgRef = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final msg = MessageModel(
      id: msgRef.id,
      senderId: currentUid,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    batch.set(msgRef, msg.toMap());

    // Update conversation with last message and increment unread count for the other user
    batch.update(_db.collection('conversations').doc(conversationId), {
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$otherUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // -------- Users --------
  /// Fetches user data in real-time
  Stream<Map<String, dynamic>> getUserStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  /// Fetches all users except current user
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs
        .where((d) => d.id != currentUid)
        .map((d) => {...d.data(), 'uid': d.id})
        .toList();
  }
}
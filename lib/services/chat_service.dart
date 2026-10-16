import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    return _auth.currentUser?.uid ?? '';
  }

  String getChatRoomId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final senderId = currentUserId;
    final trimmedMessage = message.trim();

    if (senderId.isEmpty) {
      throw Exception('You must be signed in with Firebase to send messages.');
    }

    if (receiverId.isEmpty) {
      throw Exception('Receiver is unavailable.');
    }

    if (trimmedMessage.isEmpty) {
      return;
    }

    final chatRoomId = getChatRoomId(senderId, receiverId);

    final messageReference = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final messageModel = MessageModel(
      id: messageReference.id,
      senderId: senderId,
      receiverId: receiverId,
      message: trimmedMessage,
      timestamp: DateTime.now(),
      status: 'sent',
    );

    await messageReference.set(messageModel.toMap());

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': [senderId, receiverId],
      'lastMessage': trimmedMessage,
      'lastMessageSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final senderId = currentUserId;

    if (senderId.isEmpty || otherUserId.isEmpty) {
      return const Stream.empty();
    }

    final chatRoomId = getChatRoomId(senderId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return MessageModel.fromMap(document.data(), document.id);
          }).toList();
        });
  }

  Stream<int> getUnreadCount(String otherUserId) {
    final currentId = currentUserId;

    if (currentId.isEmpty || otherUserId.isEmpty) {
      return Stream.value(0);
    }

    final chatRoomId = getChatRoomId(currentId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((document) {
            final data = document.data();

            return data['senderId'] == otherUserId && data['status'] != 'seen';
          }).length;
        });
  }

  Future<void> markMessagesAsSeen(String otherUserId) async {
    final currentId = currentUserId;

    if (currentId.isEmpty || otherUserId.isEmpty) {
      return;
    }

    final chatRoomId = getChatRoomId(currentId, otherUserId);

    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentId)
        .get();

    final batch = _firestore.batch();

    var hasUpdates = false;

    for (final document in snapshot.docs) {
      final data = document.data();

      if (data['senderId'] == otherUserId && data['status'] != 'seen') {
        batch.update(document.reference, {'status': 'seen'});

        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  Future<void> updateMessageStatus(
    String otherUserId,
    String messageId,
    String status,
  ) async {
    final currentId = currentUserId;

    if (currentId.isEmpty || otherUserId.isEmpty || messageId.isEmpty) {
      return;
    }

    final chatRoomId = getChatRoomId(currentId, otherUserId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'status': status});
  }
}

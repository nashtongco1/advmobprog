import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String status;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  bool isSentBy(String userId) {
    return senderId == userId;
  }

  factory MessageModel.fromMap(
    Map<String, dynamic> data,
    String id,
  ) {
    final timestamp = data['timestamp'];

    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
      status: data['status'] ?? 'sent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(
        timestamp,
      ),
      'status': status,
    };
  }
}
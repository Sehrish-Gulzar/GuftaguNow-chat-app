import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageid;
  String sender;
  DateTime createdon;
  String text;
  bool seen;
  bool delivered;
  bool sent;
  String imageUrl;
  String audioUrl;
  int duration; // Add this field for storing audio duration

  MessageModel({
    required this.messageid,
    required this.sender,
    required this.createdon,
    required this.text,
    required this.seen,
    required this.delivered,
    required this.sent,
    this.imageUrl = '',
    this.audioUrl = '',
    this.duration = 0, // Initialize duration as 0
  });

  Map<String, dynamic> toMap() {
    return {
      'messageid': messageid,
      'sender': sender,
      'createdon': Timestamp.fromDate(createdon),
      'text': text,
      'seen': seen,
      'delivered': delivered,
      'sent': sent,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'duration': duration, // Include duration in the map
    };
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageid: map['messageid'],
      sender: map['sender'],
      createdon: (map['createdon'] as Timestamp).toDate(),
      text: map['text'],
      seen: map['seen'] ?? false,
      delivered: map['delivered'] ?? false,
      sent: map['sent'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      duration: map['duration'] ?? 0, // Retrieve duration from the map
    );
  }
}

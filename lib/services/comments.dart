import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{

  final String id;
  final String placeId;
  final String text;
  final String userId;
  final Timestamp timestamp;
  final String useremail;
  final String username;
  final String userphoto;
  final List<String> likes;

  Comment({
    required this.id,
    required this.placeId,
    required this.text,
    required this.userId,
    required this.timestamp,
    required this.useremail,
    required this.username,
    required this.userphoto,
    this.likes = const [],
  });

  factory Comment.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      placeId: data['placeId'] ?? '',
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: data['timestamp'] ?? [],
      useremail: data['useremail'] ?? '',
      username: data['username'] ?? '',
      userphoto: data['userphoto'] ?? '',
      likes: (data['likes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      placeId: map['placeId'] ?? '',
      text: map['text'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] ?? [],
      useremail: map['useremail'] ?? '',
      username: map['username'] ?? '',
      userphoto: map['userphoto'] ?? '',
      likes: (map['likes'] as List<dynamic>?)?.cast<String>() ?? [],

    );

  }



}
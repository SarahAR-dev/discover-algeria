import 'package:cloud_firestore/cloud_firestore.dart';

class Rating{
  final String id;
  final String placeId;
  final String userId;
  final String? userEmail;
  final double rating;

  Rating({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.rating,
    this.userEmail,
  });

  factory Rating.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Rating(
      id: snapshot.id,
      placeId: data['placeId'] as String,
      userId: data['userId'] as String,
      userEmail: data['userEmail'] as String?,
      rating: (data['rating'] as num).toDouble(),
    );
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      placeId: map['placeId'] as String,
      userId: map['userId'] as String,
      userEmail: map['userEmail'] as String?,
      rating: (map['rating'] as num).toDouble(),);
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineRatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchPlaceName(String placeId) async{
    final doc =await _firestore.collection('places').doc(placeId).get();
    if(doc.exists) {
      return doc.data()?['nom'] as String;
    }else{
      throw Exception('Place not found');
    }
  }

  Stream<QuerySnapshot> fetchRatings(String placeId) {
    return _firestore
        .collection('ratings')
        .where('placeId', isEqualTo: placeId)
        .snapshots();
  }

  Future<QuerySnapshot> fetchUserRating(String placeId, String userId) {
    return _firestore
        .collection('ratings')
        .where('placeId', isEqualTo: placeId)
        .where('userId', isEqualTo: userId)
        .get();
  }

  Future<void> updateRating(String ratingId, double rating) {
    return _firestore.collection('ratings').doc(ratingId).update({
      'rating': rating,
      'timestamp': Timestamp.now(),
    });
  }

  Future<DocumentReference> submitNewRating(String placeId, String userId, String? userEmail, double rating) {
    return _firestore.collection('ratings').add({
      'placeId': placeId,
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateAverageRating(String placeId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('placeId', isEqualTo: placeId)
        .get();

    if (snapshot.docs.isEmpty) return;

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] as num).toDouble();
    }
    double average = total / snapshot.docs.length;
    average = (average * 10).truncateToDouble() / 10;
    await _firestore.collection('places').doc(placeId).set({
      'rating': average,
    }, SetOptions(merge: true));
  }
}
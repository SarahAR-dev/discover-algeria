import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnlineFavoritesService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserFavoritesStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }


  Future<void> removeFavorite(String docId) async {
    await _firestore.collection('favorites').doc(docId).delete();

  }
}
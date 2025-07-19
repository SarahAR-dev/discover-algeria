import 'package:cloud_firestore/cloud_firestore.dart';
class OnlineCommentService {

  Future<void> addComment(String userId, List<dynamic> userinfo, String placeId, String text) async {
    await FirebaseFirestore.instance.collection('comments').add({
      'placeId':placeId,
      'text': text,
      'timestamp': Timestamp.now(),
      'userId': userId,
      'userIdentifier': userinfo[0],
      'userName': userinfo[1] ?? userinfo[0]?.split('@')[0] ?? 'Utilisateur',
      'userPhotoURL': userinfo[2],
      'likes': [], // Initialiser le tableau des likes
    });
  }

  Stream<QuerySnapshot> getComments(String placeId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('placeId', isEqualTo: placeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteComment(String commentId, String userId) async {
    await FirebaseFirestore.instance.collection('comments').doc(commentId).delete();
  }

  Future<void> toggleLike(String commentId, FieldValue updatedlikes) async {
    await FirebaseFirestore.instance.collection('comments').doc(commentId).update({
      'likes': updatedlikes,
    });
  }
}
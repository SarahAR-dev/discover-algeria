import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Vérifier si l'utilisateur peut commenter
  bool canUserComment() {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  // Obtenir l'utilisateur actuel
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Récupérer les commentaires d'un lieu
  Stream<QuerySnapshot> getCommentsForPlace(String placeId) {
    return _firestore
        .collection('comments')
        .where('placeId', isEqualTo: placeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Charger les commentaires (alternative au Stream)
  Future<List<QueryDocumentSnapshot>> loadCommentsForPlace(String placeId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('placeId', isEqualTo: placeId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      print("Erreur lors du chargement des commentaires: $e");
      throw Exception("Impossible de charger les commentaires: $e");
    }
  }

  // Ajouter un commentaire
  Future<void> addComment(String placeId, String commentText) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw Exception('Utilisateur non connecté');
    }

    if (commentText.trim().isEmpty) {
      throw Exception('Le commentaire ne peut pas être vide');
    }

    try {
      await _firestore.collection('comments').add({
        'placeId': placeId,
        'text': commentText.trim(),
        'timestamp': Timestamp.now(),
        'userId': user.uid,
        'userIdentifier': user.email,
        'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur',
        'userPhotoURL': user.photoURL,
        'likes': [],
      });

      print("Commentaire ajouté avec succès pour le lieu: $placeId");
    } catch (e) {
      print("Erreur lors de l'ajout du commentaire: $e");
      throw Exception("Impossible d'ajouter le commentaire: $e");
    }
  }

  // Supprimer un commentaire
  Future<bool> deleteComment(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("Erreur: Aucun utilisateur connecté");
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer le document pour vérifier l'auteur
      final DocumentSnapshot commentDoc = await _firestore.collection('comments').doc(commentId).get();

      if (!commentDoc.exists) {
        print("Erreur: Commentaire $commentId introuvable");
        return false;
      }

      final commentData = commentDoc.data() as Map<String, dynamic>;

      // Vérifier si l'utilisateur est l'auteur
      if (commentData['userId'] != user.uid) {
        print("Erreur: L'utilisateur ${user.uid} n'est pas autorisé à supprimer le commentaire $commentId");
        throw Exception('Vous n\'êtes pas autorisé à supprimer ce commentaire');
      }

      // Supprimer le commentaire
      await _firestore.collection('comments').doc(commentId).delete();

      print("Commentaire $commentId supprimé avec succès");
      return true;
    } catch (e) {
      print("Erreur lors de la suppression du commentaire: $e");
      throw e;
    }
  }

  // Ajouter/retirer un like
  Future<void> toggleLike(String commentId, List<String> currentLikes) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.isAnonymous) {
        print("Erreur: Utilisateur non connecté ou anonyme");
        throw Exception('Utilisateur non connecté');
      }

      final String userId = user.uid;
      final bool isLiked = currentLikes.contains(userId);

      print("Toggle like pour commentaire $commentId par utilisateur $userId (actuellement ${isLiked ? 'aimé' : 'non aimé'})");

      if (isLiked) {
        // Retirer le like
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
        print("Like retiré avec succès");
      } else {
        // Ajouter le like
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
        print("Like ajouté avec succès");
      }
    } catch (e) {
      print("Erreur lors du toggle like: $e");
      throw e;
    }
  }

  // Compter les commentaires pour un lieu
  Future<int> getCommentCount(String placeId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('placeId', isEqualTo: placeId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Erreur lors du comptage des commentaires: $e");
      return 0;
    }
  }
}
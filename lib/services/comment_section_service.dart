import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/comments.dart';
import '../services/online_comment_service.dart';

class CommentSectionService {
  final OnlineCommentService onlineCommentService = OnlineCommentService();

  Future<void> addComment(String userId, List<dynamic> userInfo, String placeId, String text) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;


    if (isOnline) {
      await onlineCommentService.addComment(userId, userInfo, placeId, text);
    } else {
      // Optionally handle offline comments here if needed
    }
  }

  Stream<List<Comment>> getComments(String placeId) async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      yield* onlineCommentService.getComments(placeId).map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return [];
        }
        return snapshot.docs
            .map((comment) => Comment.fromSnapshot(comment))
            .toList();
      });
    } else {
      // Handle offline or yield an empty list
      yield []; // optional fallback
    }
  }

  Future<void> deleteComment(String commentId, String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      await onlineCommentService.deleteComment(commentId, userId);
    } else {
      // Optionally handle offline comment deletion here if needed
    }

  }

  Future<void> toggleLike(String commentId, FieldValue updatedlikes) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      await onlineCommentService.toggleLike(commentId, updatedlikes);
    } else {
      // Optionally handle offline like toggling here if needed
    }
  }

}
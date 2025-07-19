import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/rating.dart';
import 'online_rating_service.dart';

class RatingSystemService{
  final OnlineRatingService ratingService = OnlineRatingService();

  Future<String> fetchPlaceName(String placeId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      String nom = await ratingService.fetchPlaceName(placeId);
      if( nom != null){return nom;}else{return '';}
    }else{
      return '';
    }
  }

  Stream<List<Rating>> fetchRatings(String placeId) async*{
    final connectivityResult = Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if(isOnline){
      yield* ratingService.fetchRatings(placeId).map((snapshot) {
        return snapshot.docs
            .map((doc) => Rating.fromSnapshot(doc))
            .toList();
      });
    }else{
      yield[];
    }
  }

  Future<Rating?> fetchUserRating(String placeId, String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      final snapshot = await ratingService.fetchUserRating(placeId, userId);
      if (snapshot.docs.isNotEmpty) {
        return Rating.fromSnapshot(snapshot.docs.first);
      } else {
        return null; // Aucun rating trouvé
      }
    } else {
      return null; // Hors ligne
    }
  }


  Future<void> updateRating(String ratingId,double rating) async {
    final connectivityResult = Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if(isOnline){
      ratingService.updateRating(ratingId, rating);
    }else{

    }
  }

  Future<Rating?> submitNewRating(placeId,userId,userEmail,rating) async {
    final connectivityResult = Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      final snapshot = await ratingService.submitNewRating(placeId, userId,userEmail,rating);
      return Rating.fromSnapshot(snapshot as DocumentSnapshot<Object?>);
    } else {}
  }

  Future<void> updateAverageRating(String placeId) async {
    final connectivityResult = Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if(isOnline){
      ratingService.updateAverageRating(placeId);
    }else{

    }
  }

}
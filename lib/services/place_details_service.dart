import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/places.dart';
import 'online_placeD_service.dart';

class PlaceDetailsService{
  final OnlinePlaceDService onlineService = OnlinePlaceDService();

  Future<Place?> fetchPlaceData(String placeId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;


    if (isOnline) {
      final place =await onlineService.getPlace(placeId);
      if (place.exists) {
        return Place.fromSnapshot(place);
      }
    } else {
      // Optionally return offline data
    }
  }

  Future<Place?> checkIfFavorite(String userId, String placeId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      final placeinafav = await onlineService.checkFavorite(userId, placeId);
      if (placeinafav.docs.isNotEmpty) {
        return Place.fromSnapshot(placeinafav.docs.first);
      }
    } else {
      // Optional: Handle offline check here if you're caching favorites locally
    }

  }

  Future<void> toggleFavorite(String userId, String placeId,bool isFavorite, List<dynamic> placeinfo) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      await onlineService.toggleFavorite(userId, placeId, isFavorite, placeinfo);
    } else {
      // Optional: Handle offline toggle here if you're caching favorites locally
    }
  }

}
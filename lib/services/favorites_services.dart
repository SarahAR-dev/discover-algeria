import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/favorites.dart';
import 'online_favorites_service.dart';

class FavoritesService {
  final OnlineFavoritesService onlineService = OnlineFavoritesService();

  Stream<List<Favorites>> getFavorites() async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      yield* onlineService.getUserFavoritesStream().map((snapshot) {
        return snapshot.docs
            .map((doc) => Favorites.fromSnapshot(doc))
            .toList();
      });
    }else {
      // offline data yield
      yield [];
    }
  }

  Future<void> removeFavorite(String docId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      await onlineService.removeFavorite(docId);
    } else {
      //offline handle
    }
  }

}
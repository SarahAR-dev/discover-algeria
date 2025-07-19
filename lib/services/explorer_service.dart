import 'package:app_pfe/services/offline_explorer_service.dart';
import 'package:app_pfe/services/sql_db.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_pfe/services/places.dart';
import 'package:app_pfe/services/recommendations.dart';
import 'online_explorer_service.dart';

class ExplorerService {
  final OnlineExplorerService onlineService = OnlineExplorerService();
  final OfflineExplorerService offlineService = OfflineExplorerService(sqlDb: SqlDb());

  Stream<List<String>> getCarouselImages() async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      List carouselImages =await onlineService.getCarouselImages().map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.get('imageUrl'))
            .toList();
      }).first;
      yield carouselImages as List<String>;
      }
    else {
      // Optionally return offline data
      yield[
        'assets/images/header_background.jpg',
        'assets/images/header_background_2.jpg',
        'assets/images/header_background_3.jpg',
        'assets/images/header_background_4.jpg',
        'assets/images/header_background_5.jpg',
      ];
  }
  }

  Stream<List<Place>> getPlaces() async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      yield* onlineService.getPlaces().map((snapshot) {
        return snapshot.docs.map((doc) => Place.fromSnapshot(doc)).toList();
      });
    } else {
      final results = await offlineService.getPlaces();
      final places = results.map((row) => Place.fromMap(row)).toList();
      yield places;
    }
  }


  Stream<List<Recommend>> getUserRecommendations(String userId) async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      yield* onlineService.getUserRecommendations(userId).map((snapshot) {
        return snapshot.docs
            .map((doc) => Recommend.fromSnapshot(doc))
            .toList();
      });
    } else {
      // Optionally return offline data
      final results = await offlineService.getUserRecommendations(userId);
      final rec = results.map((row) => Recommend.fromMap(row)).toList();
      yield rec;
    }
  }
}

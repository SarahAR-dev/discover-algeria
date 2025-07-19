import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/places.dart';
import '../services/online_search_service.dart';
import 'offline_search_service.dart';

class SearchService {

  static Stream<List<Place>> searchPlaces(String searchTerm, String? selectedCategory) async* {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      yield* OnlineSearchService.getFilteredQuery(searchTerm, selectedCategory).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Place.fromSnapshot(doc)).toList();
      });
    } else {
      //offline data yield
      yield[];
      //yield* Stream.fromFuture(OfflineSearchService.searchPlaces(searchTerm, selectedCategory),);
    }
  }
}

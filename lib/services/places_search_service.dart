
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceSearchService {
  static Query? getFilteredQuery(String searchTerm, String? selectedCategory) {
    if (searchTerm.isEmpty) return null; // Force user to enter search

    Query query = FirebaseFirestore.instance.collection('places').where(
      Filter.or(
        Filter.and(
          Filter('nom', isGreaterThanOrEqualTo: searchTerm),
          Filter('nom', isLessThanOrEqualTo: '$searchTerm\uf8ff'),
        ),
        Filter('wilaya', isEqualTo: searchTerm),
      ),
    );

    if (selectedCategory != null) {
      query = query.where('categorie', arrayContains:  selectedCategory);
    }

    return query;
  }
}


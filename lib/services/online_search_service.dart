import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineSearchService {
  static Query getFilteredQuery(String searchTerm, String? selectedCategory) {

    Query query = FirebaseFirestore.instance.collection('places').where(
      Filter.or(
        Filter.and(
          Filter('nom', isGreaterThanOrEqualTo: searchTerm),
          Filter('nom', isLessThanOrEqualTo: '$searchTerm\uf8ff'),
        ),
        Filter.and(
          Filter('nomin', isGreaterThanOrEqualTo: searchTerm.toLowerCase()),
          Filter('nomin', isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff'),
        ),
        Filter.and(
          Filter('wilaya', isGreaterThanOrEqualTo: searchTerm.toLowerCase()),
          Filter('wilaya', isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff'),
        ),
      ),
    );

    if (selectedCategory != null) {
      query = query.where('categorie', arrayContains:  selectedCategory);
    }
    /* else if (selectedtag != null) {
      query = query.where('tags', arrayContains:  selectedtag);
    }*/
    return query;
  }
}
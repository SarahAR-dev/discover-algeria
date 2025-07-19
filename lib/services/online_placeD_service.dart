import 'package:cloud_firestore/cloud_firestore.dart';

class OnlinePlaceDService {
  Future<DocumentSnapshot<Map<String, dynamic>>> getPlace(String placeId) async {
    return await FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .get();

  }
  Future<QuerySnapshot<Map<String, dynamic>>> checkFavorite(String userId,String placeId) async {
    return await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('placeId', isEqualTo: placeId)
        .get();
  }
  Future<void> toggleFavorite(String userId, String placeId,bool isFavorite,List<dynamic> placeinfo) async {
    final favCollection = FirebaseFirestore.instance.collection('favorites');

    if (isFavorite) {
      // 1. Add to favorites
      await favCollection.add({
        'userId': userId,
        'placeId': placeId,
        'nom': placeinfo[0],
        'wilaya': placeinfo[1],
        'images': placeinfo[2],
        'addedAt': FieldValue.serverTimestamp(),
      });
    }else {
      final doc =
      await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .get();

      for (var document in doc.docs) {
        await document.reference.delete();
      }
    }
    // 2. Fetch all favorites for this user
    final favSnapshot = await favCollection
        .where('userId', isEqualTo: userId)
        .get();

    // 3. Initialize scoring maps
    Map<String, int> recCateg = {};
    Map<String, int> recWilaya = {};

    for (var favDoc in favSnapshot.docs) {
      final placeId = favDoc['placeId'];

      // 4. Fetch place document
      final placeDoc = await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .get();

      if (placeDoc.exists) {
        // Score categories
        final categories = placeDoc['categorie'] as List<dynamic>? ?? [];
        for (var cat in categories) {
          if (cat is String) {
            recCateg[cat] = (recCateg[cat] ?? 0) + 1;
          }
        }

        // Score wilaya
        final wilaya = placeDoc['wilaya'];
        if (wilaya is String) {
          recWilaya[wilaya] = (recWilaya[wilaya] ?? 0) + 1;
        }
      }
    }

    // 5. Sort and get top 2 categories and wilayas
    final topCategories = recCateg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWilayas = recWilaya.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTwoCategories = topCategories.take(2).map((e) => e.key).toList();
    final topTwoWilayas = topWilayas.take(2).map((e) => e.key).toList();

    // 6. Update or create recommendation document
    final recommendationCollection = FirebaseFirestore.instance.collection('recommendation');

    final querySnapshot = await recommendationCollection
        .where('userId', isEqualTo: userId)
        .get();

    final dataToSave = {
      'userId': userId,
      'categ': topTwoCategories,
      'wilaya': topTwoWilayas,
    };

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.set(dataToSave);
    } else {
      await recommendationCollection.add(dataToSave);
    }
  }
}

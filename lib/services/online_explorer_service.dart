import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineExplorerService{

  Stream<QuerySnapshot> getCarouselImages(){
    return FirebaseFirestore.instance.collection('places').limit(5).snapshots();
  }

  Stream<QuerySnapshot> getPlaces(){
    return FirebaseFirestore.instance.collection('places').snapshots();
  }

  Stream<QuerySnapshot> getUserRecommendations(String uid){
    return FirebaseFirestore.instance.collection('recommendation').where('userId', isEqualTo: uid).snapshots();
  }
}
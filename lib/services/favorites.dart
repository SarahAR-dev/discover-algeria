import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Favorites {
  final String id;
  final String userId;
  final String placeId;
  final DateTime addedAt;//to verify
  final String nom;
  final String wilaya;
  final List<String> images;

  Favorites({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.addedAt,
    required this.nom,
    required this.wilaya,
    required this.images,
  });

  factory Favorites.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Favorites(
      id: doc.id,
      userId: data['userId'],
      placeId: data['placeId'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nom: data['nom'] ?? '',
      wilaya: data['wilaya'] ?? '',
      images: _decodeJsonS(data['images'] ?? []),
    );
  }

  factory Favorites.fromMap(Map<String, dynamic> map) {
    return Favorites(
      id: map['id'] ,
      userId: map['userId'],
      placeId: map['placeId'],
      addedAt: map['addedAt'] ?? DateTime.now(),
      nom: map['nom'] ?? '',
      wilaya: map['wilaya'] ?? '',
      images: _decodeJsonS(map['images'] ?? []),
    );
  }

  static List<String> _decodeJsonS(dynamic value) {
    try {
      if (value is String) {
        return List<String>.from(jsonDecode(value));
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

}
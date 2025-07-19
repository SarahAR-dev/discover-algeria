import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String nom;
  final String nomin;
  final String wilaya;
  final String description;
  final List<String> categorie;
  final List<String> tags;
  final List<String> images;
  final GeoPoint localisation;
  final double rating;

  Place({
    required this.id,
    required this.nom,
    required this.nomin,
    required this.wilaya,
    required this.description,
    required this.categorie,
    required this.tags,
    required this.images,
    required this.localisation,
    required this.rating,
  });

  factory Place.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      nom: data['nom'] ?? '',
      nomin: data['nomin'] ?? '',
      wilaya: data['wilaya'] ?? '',
      description: data['description'] ?? '',
      categorie: _decodeJsonS(data['categorie'] ?? []),
      tags: _decodeJsonS(data['tags'] ?? []),
      images: _decodeJsonS(data['images'] ?? []),
      localisation: data['localisation'] ?? [],
      rating: data['rating'] ?? 0.0,
    );
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      nom: map['nom'] ?? '',
      nomin: map['nomin'] ?? '',
      description: map['description'] ??'',
      wilaya: map['wilaya'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      categorie: _decodeJsonS(map['categorie'] ?? []),
      tags: _decodeJsonS(map['tags'] ??[]),
      images: _decodeJsonS(map['images'] ?? []),
      localisation: map['localisation'] ?? [],
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

  static List<double> _decodeJsonD(dynamic value) {
    try {
      if (value is List) {
        return value.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }



}

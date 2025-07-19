import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Recommend {
  final String id;
  final String userId;
  final List<String> categ;
  final List<String> wilaya;

  Recommend({required this.id,
    required this.userId,
    required this.categ,
    required this.wilaya,});

  factory Recommend.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recommend(
      id: doc.id,
      userId: data['userId'] ?? '',
      categ: _toStringList(data['categ'] ?? []),
      wilaya: _toStringList(data['wilaya'] ?? []),
    );
  }

  factory Recommend.fromMap(Map<String, dynamic> map) {
    return Recommend(
      id: map['id'],
      userId: map['userId'] ?? '',
      categ: _toStringList(map['categ'] ?? []),
      wilaya: _toStringList(map['wilaya'] ?? []),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

}
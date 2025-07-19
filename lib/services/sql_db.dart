import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'dblocal.db');
    print('Database path: $path');
    Database mydb = await openDatabase(path, onCreate: _onCreate, version: 6, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE places (
        id TEXT PRIMARY KEY,
        nom TEXT,
        nomin TEXT,
        description TEXT,
        wilaya TEXT,
        rating REAL,
        categorie TEXT,
        tags TEXT,
        images TEXT,
        localisation TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        likes TEXT,
        placeId TEXT,
        text TEXT,
        timestamp TEXT,
        userId TEXT,
        userIdentifier TEXT,
        userName TEXT,
        userPhotoURL TEXT,
        FOREIGN KEY(placeId) REFERENCES places(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ratings (
        id TEXT PRIMARY KEY,
        placeId TEXT,
        rating REAL,
        userId TEXT,
        userEmail TEXT,
        FOREIGN KEY(placeId) REFERENCES places(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        nom TEXT,
        wilaya TEXT,
        userId TEXT,
        placeId TEXT,
        addedAt TEXT,
        images TEXT,
        FOREIGN KEY(userId) REFERENCES users(uid),
        FOREIGN KEY(placeId) REFERENCES places(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE recommendation (
        userId TEXT PRIMARY KEY,
        wilaya TEXT,
        categ TEXT,
        FOREIGN KEY(userId) REFERENCES users(uid)
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        email TEXT,
        displayName TEXT,
        photoURL TEXT
      )
    ''');

    await db.execute("CREATE INDEX idx_places_nom ON places(nom)");
    await db.execute("CREATE INDEX idx_places_nomin ON places(nomin)");
    await db.execute("CREATE INDEX idx_places_wilaya ON places(wilaya)");
    await db.execute("CREATE INDEX idx_places_categorie ON places(categorie)");
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        nom TEXT,
        wilaya TEXT,
        userId TEXT,
        placeId TEXT,
        addedAt TEXT,
        images TEXT,
        FOREIGN KEY(userId) REFERENCES users(uid),
        FOREIGN KEY(placeId) REFERENCES places(id)
      )
    ''');
  }

  selectData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}

String safeJsonEncode(dynamic data) {
  try {
    return jsonEncode(data ?? []);
  } catch (e) {
    return '[]';
  }
}
/*Future<void> preloadPlaceImages(List<Map<String, dynamic>> places) async {
  for (final place in places) {
    final imagesJson = place['images']; // This is a JSON string
    final List<dynamic> imagesList = imagesJson != null
        ? jsonDecode(imagesJson)
        : [];

    for (final imageUrl in imagesList) {
      if (imageUrl is String && imageUrl.isNotEmpty) {
        final provider = CachedNetworkImageProvider(imageUrl);
        // Start image loading and caching
        await precacheImage(provider, null);
      }
    }
  }
}*/

Future<void> syncDataToLocal(Database db) async {

  ///************************************************************/
  final placeSnap = await FirebaseFirestore.instance.collection('places').get();
  final places = <Map<String, dynamic>>[];
  for (var doc in placeSnap.docs) {
    try {
      final data = doc.data();
      await db.insert('places', {
        'id': doc.id,
        'nom': data['nom'] ?? 'Sans Nom',
        'nomin': data['nomin'] ?? 'sans nom',
        'description': data['description'] ?? 'sans description',
        'wilaya': data['wilaya'] ?? 'Emplacement inconnu',
        'rating': data.containsKey('rating') ? data['rating'] ?? 0.0 : 0.0,
        'categorie': safeJsonEncode(data['categorie']),
        'tags': safeJsonEncode(data['tags']),
        'images': safeJsonEncode(data['images']),
        'localisation': safeJsonEncode(data['localisation']),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

    } catch (e) {
      print("Error inserting place: $e");
    }
    // After syncing all places, preload their images:
    //await preloadPlaceImages(places);

  }
  print('Synced ${placeSnap.docs.length} places');


  ///************************************************************/
  // 1. Récupérer tous les IDs de commentaires dans Firestore
  final commentSnap = await FirebaseFirestore.instance.collection('comments').get();
  final firestoreCIds = commentSnap.docs.map((doc) => doc.id).toSet();

  // 2. Récupérer tous les IDs de commentaires dans la base locale
  final localCRows = await db.query('comments', columns: ['id']);
  final localCIds = localCRows.map((row) => row['id'] as String).toSet();

  // 3. Trouver les IDs à supprimer localement (présents localement mais plus dans Firestore)
  final CidsToDelete = localCIds.difference(firestoreCIds);

  // 4. Supprimer ces entrées dans la base locale
  for (final id in CidsToDelete) {
    await db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }

  // 5. Insérer ou remplacer les documents Firestore dans la base locale (comme avant)
  for (var doc in commentSnap.docs) {
    try {
      final data = doc.data();
      await db.insert('comments', {
        'id': doc.id,
        'likes': safeJsonEncode(data['likes']),
        'placeId': data['placeId'],
        'text': data['text'] ?? 'commentaire vide',
        'timestamp': (data['timestamp'] as Timestamp).millisecondsSinceEpoch.toString(),
        'userId': data['userId'],
        'userIdentifier': data['userIdentifier'],
        'userName': data['userName'],
        'userPhotoURL': data['userPhotoURL'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error inserting comment: $e");
    }
  }
  print('Synced ${commentSnap.docs.length} comments');

  ///************************************************************/

  // 1. Récupérer tous les IDs de ratings dans Firestore
  final rateSnap = await FirebaseFirestore.instance.collection('ratings').get();
  final firestoreRIds = rateSnap.docs.map((doc) => doc.id).toSet();

  // 2. Récupérer tous les IDs de ratings dans la base locale
  final localRRows = await db.query('ratings', columns: ['id']);
  final localRIds = localRRows.map((row) => row['id'] as String).toSet();

  // 3. Trouver les IDs à supprimer localement (présents localement mais plus dans Firestore)
  final RidsToDelete = localRIds.difference(firestoreRIds);

  // 4. Supprimer ces entrées dans la base locale
  for (final id in RidsToDelete) {
    await db.delete('ratings', where: 'id = ?', whereArgs: [id]);
  }
  // 5. Insérer ou remplacer les documents Firestore dans la base locale (comme avant)
  for (var doc in rateSnap.docs) {
    try {
      final data = doc.data();
      await db.insert('ratings', {
        'id': doc.id,
        'placeId': data['placeId'],
        'rating': data['rating'],
        'userId': data['userId'],
        'userEmail': data['userEmail'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error inserting rating: $e");
    }
  }
  print('Synced ${rateSnap.docs.length} ratings');

///************************************************************/
  // 1. Récupérer tous les IDs de favorites dans Firestore
  final favSnap = await FirebaseFirestore.instance.collection('favorites').get();
  final firestoreFIds = favSnap.docs.map((doc) => doc.id).toSet();

  // 2. Récupérer tous les IDs de favorites dans la base locale
  final localFRows = await db.query('favorites', columns: ['id']);
  final localFIds = localFRows.map((row) => row['id'] as String).toSet();

  // 3. Trouver les IDs à supprimer localement (présents localement mais plus dans Firestore)
  final FidsToDelete = localFIds.difference(firestoreFIds);
  print('FidsToDelete: ${FidsToDelete.length}');

  // 4. Supprimer ces entrées dans la base locale
  for (final id in FidsToDelete) {
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  // 5. Insérer ou remplacer les documents Firestore dans la base locale (comme avant)
  for (var doc in favSnap.docs) {
    try {
      final data = doc.data();
      await db.insert('favorites', {
        'id': doc.id,
        'nom': data['nom'],
        'wilaya': data['wilaya'],
        'userId': data['userId'],
        'placeId': data['placeId'],
        'addedAt': safeJsonEncode(data['addedAt']),
        'images': safeJsonEncode(data['images']),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error inserting favorite: $e");
    }
  }
  print('Synced ${favSnap.docs.length} favorites');

  ///************************************************************/
  final recSnap = await FirebaseFirestore.instance.collection('recommendation').get();
  final firestoreRecIds = recSnap.docs.map((doc) => doc.id).toSet();

  // 2. Récupérer tous les IDs de ratings dans la base locale
  final localRecRows = await db.query('recommendation', columns: ['id']);
  final localRecIds = localRecRows.map((row) => row['id'] as String).toSet();

  // 3. Trouver les IDs à supprimer localement (présents localement mais plus dans Firestore)
  final RecidsToDelete = localRecIds.difference(firestoreRecIds);

  // 4. Supprimer ces entrées dans la base locale
  for (final id in RecidsToDelete) {
    await db.delete('ratings', where: 'id = ?', whereArgs: [id]);
  }
  for (var doc in recSnap.docs) {
    try {
      final data = doc.data();
      await db.insert('recommendation', {
        'userId': doc['userId'],
        'wilaya': safeJsonEncode(data['wilaya']),
        'categ': safeJsonEncode(data['categ']),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error inserting recommendation: $e");
    }
  }
  print('Synced ${recSnap.docs.length} recommendations');

}

Future<Map<String, dynamic>?> getLocalUser(Database db, String uid) async {
  final results = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
  if (results.isNotEmpty) {
    return results.first;
  }
  return null;
}

Future<void> syncCurrentUserToLocal(Database db) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await db.insert('users', {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<void> syncAllToLocal() async {
  final localDb = await SqlDb().db;
  if (localDb != null) {
    await syncDataToLocal(localDb);
    await syncCurrentUserToLocal(localDb);
  }
}

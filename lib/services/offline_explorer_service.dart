import 'package:sqflite/sqflite.dart';
import 'sql_db.dart';

class OfflineExplorerService {
  final SqlDb sqlDb;

  OfflineExplorerService({required this.sqlDb});

  /*/// Get top 5 places for carousel (offline)
  Future<List<Map<String, dynamic>>> getCarouselImages() async {
    // For example, get first 5 places ordered by rating descending
    final sql = 'SELECT * FROM places ORDER BY rating DESC LIMIT 5';
    return await sqlDb.selectData(sql);
  }*/


  Future<List<Map<String, dynamic>>> getPlaces() async {
    final sql = 'SELECT * FROM places';
    return await sqlDb.selectData(sql);
  }


  Future<List<Map<String, dynamic>>> getUserRecommendations(String uid) async {
    final sql = 'SELECT * FROM recommendation WHERE userId = ?';
    final db = await sqlDb.db;
    if (db == null) return [];
    final result = await db.query(
      'recommendation',
      where: 'userId = ?',
      whereArgs: [uid],
    );
    return result;
  }
}

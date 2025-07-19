/*import '../places.dart'; // Ensure Place.fromMap is implemented
import 'sql_db.dart';    // Your SqlDb class

class OfflineSearchService {
  static Future<List<Place>> searchPlaces(String searchTerm, String? selectedCategory) async {
    final db = await SqlDb().db;
    if (db == null) return [];

    // Build SQL query
    final search = searchTerm.trim().toLowerCase();
    final category = selectedCategory?.toLowerCase();

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (search.isNotEmpty) {
      whereClauses.add('(LOWER(nom) LIKE ? OR LOWER(nomin) LIKE ? OR LOWER(description) LIKE ?)');
      final likeQuery = '%$search%';
      whereArgs.addAll([likeQuery, likeQuery, likeQuery]);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('LOWER(categorie) LIKE ?');
      whereArgs.add('%$category%');
    }

    final sql = 'SELECT * FROM places${whereClauses.isNotEmpty ? ' WHERE ' + whereClauses.join(' AND ') : ''}';

    final results = await db.rawQuery(sql, whereArgs);

    return results.map((row) => Place.fromMap(row)).toList();
  }
}
*/
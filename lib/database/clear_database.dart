import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteDB() async {
  try {
    // Mendapatkan path database
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'strukin.db'); // Ganti dengan nama database kamu

    // Cek apakah database ada sebelum dihapus
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      print("Database berhasil dihapus");
    } else {
      print("Database tidak ditemukan");
    }
  } catch (e) {
    print("Error saat menghapus database: $e");
  }
}

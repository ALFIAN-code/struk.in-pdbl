import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'strukin.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Usersplit (
        UserID INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        avatar TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaksi (
        transaksiID INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT,
        store_name TEXT,
        struk_date TEXT,
        subtotal REAL,
        pajak REAL,
        biaya_layanan REAL,
        total REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detail_transaksi (
        DetailID INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_userID INTEGER NOT NULL,
        fk_transaksiID INTEGER NOT NULL,
        nama_barang TEXT,
        harga REAL,
        jumlah INTEGER,
        FOREIGN KEY (fk_userID) REFERENCES Usersplit(UserID) ON DELETE CASCADE,
        FOREIGN KEY (fk_transaksiID) REFERENCES transaksi(transaksiID) ON DELETE CASCADE
      )
    ''');
  }

  //CRUD Operation for each table
  //CRUD OPERATION UserSplit
  Future<int> insertUserSplit(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Usersplit', row);
  }

  Future<List<Map<String, dynamic>>> queryAllUserSplit() async {
    Database db = await database;
    return await db.query('Usersplit');
  }

  Future<Map<String, dynamic>?> getUsersplit(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'Usersplit',
      where: 'UserID = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateUserSplit(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['UserID'];
    return await db.update(
      'Usersplit',
      row,
      where: 'UserID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUserSplit(int id) async {
    Database db = await database;
    return await db.delete('Usersplit', where: 'UserID = ?', whereArgs: [id]);
  }

  //CRUD OPERATION Transaksi
  Future<int> insertTransaksi(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('transaksi', row);
  }

  Future<List<Map<String, dynamic>>> queryAllTransaksi() async {
    Database db = await database;
    return await db.query('transaksi');
  }

  Future<Map<String, dynamic>?> getTransaksi(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'transaksi',
      where: 'transaksiId = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateTransaksi(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['transaksiID'];
    return await db.update(
      'transaksi',
      row,
      where: 'transaksiID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaksi(int id) async {
    Database db = await database;
    return await db.delete(
      'transaksi',
      where: 'transaksiID = ?',
      whereArgs: [id],
    );
  }

  //CRUD OPERATION Detail Transaksi
  Future<int> insertDetailTransaksi(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('detail_transaksi', row);
  }

  Future<List<Map<String, dynamic>>> queryAllDetailTransaksi() async {
    Database db = await database;
    return await db.query('detail_transaksi');
  }

  Future<Map<String, dynamic>?> getDetailTransaksi(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'detail_transaksi',
      where: 'DetailId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> updateDetailTransaksi(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['DetailID'];
    return await db.update(
      'detail_transaksi',
      row,
      where: 'DetailID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDetailTransaksi(int id) async {
    Database db = await database;
    return await db.delete(
      'detail_transaksi',
      where: 'DetailID = ?',
      whereArgs: [id],
    );
  }
}

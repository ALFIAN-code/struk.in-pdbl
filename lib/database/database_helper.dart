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
    // // Insert Usersplit
    //lkjljk
    // await db.insert('Usersplit', {'username': 'Paritispan 1', 'avatar': 'avatar1.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 2', 'avatar': 'avatar2.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 3', 'avatar': 'avatar3.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 4', 'avatar': 'avatar4.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 5', 'avatar': 'avatar5.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 6', 'avatar': 'avatar6.png'});
    // await db.insert('Usersplit', {'username': 'Partisipan 7', 'avatar': 'avatar7.png'});
  }

  //CRUD Operation for each table
  //UserSplit
  
}

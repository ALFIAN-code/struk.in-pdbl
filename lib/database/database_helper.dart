import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:strukin/model/struk_model.dart';

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
    // Tabel user
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Usersplit (
        UserID INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        avatar TEXT
      )
    ''');

    // Tabel transaksi
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

    // Tabel detail_transaksi
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detail_transaksi (
        DetailID INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_transaksiID INTEGER NOT NULL,
        nama_barang TEXT,
        harga REAL,
        jumlah INTEGER,
        FOREIGN KEY (fk_transaksiID) REFERENCES transaksi(transaksiID) ON DELETE CASCADE
      )
    ''');

    // Tabel bridging: detail_user_split
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detail_user_split (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_detailID INTEGER NOT NULL,
        fk_userID INTEGER NOT NULL,
        portion REAL,
        FOREIGN KEY(fk_detailID) REFERENCES detail_transaksi(DetailID) ON DELETE CASCADE,
        FOREIGN KEY(fk_userID) REFERENCES Usersplit(UserID) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // INSERT FULL TRANSAKSI (Transaksi + Detail + UserSplit bridging)
  // ---------------------------------------------------------------------------
  Future<int> insertFullTransaksi(TransaksiModel transaksiModel) async {
    final db = await database;

    // Gunakan transaction agar bersifat atomic
    return await db.transaction((txn) async {
      // 1. Insert ke tabel transaksi
      final transaksiID = await txn.insert('transaksi', {
        'image_path': transaksiModel.imagePath,
        'store_name': transaksiModel.storeName,
        'struk_date': transaksiModel.strukDate,
        'subtotal': transaksiModel.subtotal,
        'pajak': transaksiModel.pajak,
        'biaya_layanan': transaksiModel.biayaLayanan,
        'total': transaksiModel.total,
      });

      // 2. Untuk setiap detail di transaksiModel
      for (final detail in transaksiModel.detailTransaksis) {
        // Insert detail_transaksi
        final detailID = await txn.insert('detail_transaksi', {
          'fk_transaksiID': transaksiID,
          'nama_barang': detail.namaBarang,
          'harga': detail.harga,
          'jumlah': detail.jumlah,
        });

        // 3. Untuk setiap bridging user di detail
        for (final detailUser in detail.userSplits) {
          int userID = 0;

          // (Opsional) Insert user ke tabel Usersplit jika user belum ada
          //   - Atau jika user memang selalu baru.
          //   - Jika ingin menghindari duplikasi, kita perlu cek dulu.
          if (detailUser.user != null) {
            userID = await txn.insert('Usersplit', {
              'username': detailUser.user!.username,
              'avatar': detailUser.user!.avatar,
            });
          } else {
            userID = detailUser.fkUserID;
          }

          // Insert ke bridging table detail_user_split
          await txn.insert('detail_user_split', {
            'fk_detailID': detailID,
            'fk_userID': userID,
            'portion': detailUser.portion,
          });
        }
      }

      return transaksiID; // Kembalikan ID transaksi yang baru dibuat
    });
  }

  // ---------------------------------------------------------------------------
  // GET ALL TRANSAKSI DENGAN DETAIL + USER (Many-to-Many)
  // ---------------------------------------------------------------------------
  Future<List<TransaksiModel>> getAllTransaksiWithDetails() async {
    final db = await database;

    // 1. Ambil semua data transaksi
    final transaksiMaps = await db.query('transaksi');

    List<TransaksiModel> allTransaksi = [];

    for (var tMap in transaksiMaps) {
      // Buat object TransaksiModel dari Map
      TransaksiModel transaksi = TransaksiModel.fromMap(tMap);

      // 2. Ambil semua detail_transaksi yg berelasi dengan transaksi ini
      final detailMaps =
          await db.query(
                'detail_transaksi',
                where: 'fk_transaksiID = ?',
                whereArgs: [transaksi.transaksiID],
              )
              as List<DetailTransaksiModel>;

      List<DetailTransaksiModel> detailList = [];

      for (var dMap in detailMaps) {
        // Buat object DetailTransaksiModel
        DetailTransaksiModel detail = DetailTransaksiModel(
          detailID: dMap.detailID,
          fkTransaksiID: dMap.fkTransaksiID,
          namaBarang: dMap.namaBarang,
          harga: dMap.harga != null ? dMap.harga?.toDouble() : null,
          jumlah: dMap.jumlah,
        );

        // 3. Dari detail, ambil bridging detail_user_split
        final bridgingMaps = await db.query(
          'detail_user_split',
          where: 'fk_detailID = ?',
          whereArgs: [detail.detailID],
        );

        List<DetailUserSplitModel> bridgingList = [];

        for (var bMap in bridgingMaps) {
          DetailUserSplitModel bridging = DetailUserSplitModel.fromMap(bMap);

          // 4. Ambil data user (Usersplit) berdasarkan fk_userID
          final userMaps = await db.query(
            'Usersplit',
            where: 'UserID = ?',
            whereArgs: [bridging.fkUserID],
          );
          if (userMaps.isNotEmpty) {
            final user = UserSplitModel.fromMap(userMaps.first);
            bridging = bridging.copyWith(user: user);
          }

          bridgingList.add(bridging);
        }

        // Update object detailTransaksiModel agar menampung bridgingList
        detail = detail.copyWith(userSplits: bridgingList);

        detailList.add(detail);
      }

      // 5. Masukkan list detail ke object TransaksiModel
      transaksi = transaksi.copyWith(detailTransaksis: detailList);
      allTransaksi.add(transaksi);
    }

    return allTransaksi;
  }
}

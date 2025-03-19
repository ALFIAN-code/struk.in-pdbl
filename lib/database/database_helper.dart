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
    // Tabel Usersplit
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

    // Tabel bridging detail_user_split
    await db.execute('''
    CREATE TABLE IF NOT EXISTS detail_user_split (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fk_detailID INTEGER NOT NULL,
      fk_userID INTEGER NOT NULL,
      portion REAL,
      harga_per_participant REAL,
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

    return await db.transaction((txn) async {
      // 1. Insert data transaksi utama
      final transaksiID = await txn.insert('transaksi', {
        'image_path': transaksiModel.imagePath,
        'store_name': transaksiModel.storeName,
        'struk_date': transaksiModel.strukDate,
        'subtotal': transaksiModel.subtotal,
        'pajak': transaksiModel.pajak,
        'biaya_layanan': transaksiModel.biayaLayanan,
        'total': transaksiModel.total,
      });

      // 2. Untuk setiap detail transaksi
      for (final detail in transaksiModel.detailTransaksis) {
        final detailID = await txn.insert('detail_transaksi', {
          'fk_transaksiID': transaksiID,
          'nama_barang': detail.namaBarang,
          'harga': detail.harga,
          'jumlah': detail.jumlah,
        });

        // Hitung harga per participant untuk detail ini
        double hargaPerParticipant =
            (detail.harga ?? 0) /
            (detail.userSplits.isNotEmpty ? detail.userSplits.length : 1);

        // 3. Untuk setiap user split pada detail
        for (final detailUser in detail.userSplits) {
          int userID = 0;

          // Jika ada data user, insert ke tabel Usersplit (atau cek terlebih dahulu jika sudah ada)
          if (detailUser.user != null) {
            userID = await txn.insert('Usersplit', {
              'username': detailUser.user!.username,
              'avatar': detailUser.user!.avatar,
            });
          } else {
            userID = detailUser.fkUserID;
          }

          await txn.insert('detail_user_split', {
            'fk_detailID': detailID,
            'fk_userID': userID,
            'portion': detailUser.portion,
            'harga_per_participant': hargaPerParticipant,
          });
        }
      }
      return transaksiID;
    });
  }

  // ---------------------------------------------------------------------------
  // GET SINGLE FULL TRANSAKSI DENGAN DETAIL + USER (Many-to-Many)
  // ---------------------------------------------------------------------------

  Future<TransaksiModel?> getFullTransaksi(int transaksiID) async {
    final db = await database;

    // 1. Ambil data transaksi utama
    final transaksiMaps = await db.query(
      'transaksi',
      where: 'transaksiID = ?',
      whereArgs: [transaksiID],
    );
    if (transaksiMaps.isEmpty) {
      return null;
    }
    TransaksiModel transaksi = TransaksiModel.fromMap(transaksiMaps.first);

    // 2. Ambil semua detail_transaksi yang berhubungan dengan transaksi ini
    final detailMaps = await db.query(
      'detail_transaksi',
      where: 'fk_transaksiID = ?',
      whereArgs: [transaksi.transaksiID],
    );

    List<DetailTransaksiModel> detailList = [];
    for (var dMap in detailMaps) {
      var harga = dMap['harga'] as int?;
      // Buat objek DetailTransaksiModel dari Map
      DetailTransaksiModel detail = DetailTransaksiModel(
        detailID: dMap['DetailID'] as int,
        fkTransaksiID: dMap['fk_transaksiID'] as int,
        namaBarang: dMap['nama_barang'] as String?,
        harga: harga != null ? harga.toDouble() : null,
        jumlah: dMap['jumlah'] as int?,
      );

      // 3. Ambil data bridging dari detail_user_split untuk detail ini
      final bridgingMaps = await db.query(
        'detail_user_split',
        where: 'fk_detailID = ?',
        whereArgs: [detail.detailID],
      );

      List<DetailUserSplitModel> bridgingList = [];
      for (var bMap in bridgingMaps) {
        DetailUserSplitModel bridging = DetailUserSplitModel.fromMap(bMap);

        // 4. Ambil data Usersplit untuk masing-masing bridging
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
      // Masukkan list bridging ke detail transaksi
      detail = detail.copyWith(userSplits: bridgingList);
      detailList.add(detail);
    }

    // Masukkan list detail ke transaksi utama
    transaksi = transaksi.copyWith(detailTransaksis: detailList);
    return transaksi;
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
      final detailMaps = await db.query(
        'detail_transaksi',
        where: 'fk_transaksiID = ?',
        whereArgs: [transaksi.transaksiID],
      );

      List<DetailTransaksiModel> detailList =
          detailMaps.map((dMap) {
            return DetailTransaksiModel(
              detailID: dMap['DetailID'] as int,
              fkTransaksiID: dMap['fk_transaksiID'] as int,
              namaBarang: dMap['nama_barang'] as String?,
              harga:
                  dMap['harga'] != null
                      ? (dMap['harga'] as num).toDouble()
                      : null,
              jumlah: dMap['jumlah'] as int?,
            );
          }).toList();

      // 5. Masukkan list detail ke object TransaksiModel
      transaksi = transaksi.copyWith(detailTransaksis: detailList);
      allTransaksi.add(transaksi);
    }

    return allTransaksi;
  }
}

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
      UserID TEXT PRIMARY KEY,
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
      jumlah_participant INTEGER,
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
      harga_satuan INTEGER,
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
      fk_userID TEXT NOT NULL,
      portion REAL,
      harga_per_participant REAL,
      FOREIGN KEY(fk_detailID) REFERENCES detail_transaksi(DetailID) ON DELETE CASCADE,
      FOREIGN KEY(fk_userID) REFERENCES Usersplit(UserID) ON DELETE CASCADE
    )
  ''');
  }

  Future<TransaksiModel> getTransaksiById(int transaksiID) async {
    final db = await database;
    // 1. Ambil data transaksi utama berdasarkan transaksiID
    final transaksiMaps = await db.query(
      'transaksi',
      where: 'transaksiID = ?',
      whereArgs: [transaksiID],
    );

    TransaksiModel transaksi = TransaksiModel.fromMap(transaksiMaps.single);

    // 2. Ambil semua detail_transaksi untuk transaksi ini
    final detailMaps = await db.query(
      'detail_transaksi',
      where: 'fk_transaksiID = ?',
      whereArgs: [transaksi.transaksiID],
    );

    List<DetailTransaksiModel> detailList = [];
    for (var dMap in detailMaps) {
      // Konversi harga dan jumlah agar sesuai dengan tipe data yang dibutuhkan
      var harga = dMap['harga'];
      var jumlah = dMap['jumlah'];

      DetailTransaksiModel detail = DetailTransaksiModel(
        hargaSatuan: dMap['harga_satuan'] as int,
        detailID: dMap['DetailID'] as int,
        fkTransaksiID: dMap['fk_transaksiID'] as int,
        namaBarang: dMap['nama_barang'] as String?,
        harga: harga is int ? harga.toDouble() : (harga as double),
        jumlah: jumlah is int ? jumlah : (jumlah as double).toInt(),
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

      detail = detail.copyWith(userSplits: bridgingList);
      detailList.add(detail);
    }

    // Masukkan list detail ke transaksi utama
    transaksi = transaksi.copyWith(detailTransaksis: detailList);

    return transaksi;
  }

  // ---------------------------------------------------------------------------
  // INSERT FULL TRANSAKSI (Transaksi + Detail + UserSplit bridging)
  // ---------------------------------------------------------------------------
  Future<int> insertFullTransaksi(TransaksiModel transaksiModel) async {
    final db = await database;

    return await db.transaction((txn) async {
      // 1. Insert data transaksi utama
      final transaksiID = await txn.insert(
        'transaksi',
        // {
        //   'image_path': transaksiModel.imagePath,
        //   'store_name': transaksiModel.storeName,
        //   'struk_date': transaksiModel.strukDate,
        //   'subtotal': transaksiModel.subtotal,
        //   'pajak': transaksiModel.pajak,
        //   'biaya_layanan': transaksiModel.biayaLayanan,
        //   'total': transaksiModel.total,
        //   'jumlah_participant': transaksiModel.jumlahparticipant,
        // }
        TransaksiModel(
          transaksiID: transaksiModel.transaksiID,
          imagePath: transaksiModel.imagePath,
          storeName: transaksiModel.storeName,
          strukDate: transaksiModel.strukDate,
          subtotal: transaksiModel.subtotal,
          pajak: transaksiModel.pajak,
          biayaLayanan: transaksiModel.biayaLayanan,
          total: transaksiModel.total,
          jumlahparticipant: transaksiModel.jumlahparticipant,
        ).toMap(),
      );

      // 2. Untuk setiap detail transaksi
      for (final detail in transaksiModel.detailTransaksis) {
        final detailID = await txn.insert(
          'detail_transaksi',
          // {
          //   'fk_transaksiID': transaksiID,
          //   'nama_barang': detail.namaBarang,
          //   'harga_satuan': detail.hargaSatuan,
          //   'harga': detail.harga,
          //   'jumlah': detail.jumlah,
          // }
          DetailTransaksiModel(
            fkTransaksiID: transaksiID,
            namaBarang: detail.namaBarang,
            hargaSatuan: detail.hargaSatuan,
            harga: detail.harga,
            jumlah: detail.jumlah,
          ).toMap(),
        );

        // Hitung harga per participant untuk detail ini

        // 3. Untuk setiap user split pada detail
        for (final detailUser in detail.userSplits) {
          String userID;
          // Jika data user tersedia, pastikan untuk insert/update data Usersplit
          if (detailUser.user != null && detailUser.user!.userID != null) {
            await txn.insert(
              'Usersplit',
              // {
              //   'UserID': detailUser.user!.userID,
              //   'username': detailUser.user!.username,
              //   'avatar': detailUser.user!.avatar,
              // }
              UserSplitModel(
                userID: detailUser.user!.userID,
                username: detailUser.user!.username,
                avatar: detailUser.user!.avatar,
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            userID = detailUser.user!.userID!;
          } else {
            // Jika data user tidak lengkap, gunakan fk_userID yang ada
            userID = detailUser.fkUserID!;
          }

          await txn.insert(
            'detail_user_split',
            // {
            //   'fk_detailID': detailID,
            //   'fk_userID': userID,
            //   'portion': detailUser.portion,

            //   'harga_per_participant': hargaPerParticipant,
            // }
            DetailUserSplitModel(
              fkDetailID: detailID,
              fkUserID: userID,
              portion: detailUser.portion,
              hargaPerParticipant: detailUser.hargaPerParticipant,
            ).toMap(),
          );
        }
      }
      return transaksiID;
    });
  }

  // ---------------------------------------------------------------------------
  // GET ALL TRANSAKSI DENGAN DETAIL + USER (Many-to-Many)
  // ---------------------------------------------------------------------------
  Future<List<TransaksiModel>> getAllTransaksi() async {
    final db = await database;

    // 1. Ambil semua transaksi utama
    final transaksiMaps = await db.query('transaksi');
    if (transaksiMaps.isEmpty) {
      return [];
    }

    List<TransaksiModel> transaksiList = [];

    for (var transaksiMap in transaksiMaps) {
      TransaksiModel transaksi = TransaksiModel.fromMap(transaksiMap);

      // 2. Ambil semua detail_transaksi untuk transaksi ini
      final detailMaps = await db.query(
        'detail_transaksi',
        where: 'fk_transaksiID = ?',
        whereArgs: [transaksi.transaksiID],
      );

      List<DetailTransaksiModel> detailList = [];
      for (var dMap in detailMaps) {
        var harga = dMap['harga']; // Bisa int atau double
        var jumlah = dMap['jumlah']; // Bisa int atau double

        DetailTransaksiModel detail = DetailTransaksiModel(
          hargaSatuan: dMap['harga_satuan'] as int,
          detailID: dMap['DetailID'] as int,
          fkTransaksiID: dMap['fk_transaksiID'] as int,
          namaBarang: dMap['nama_barang'] as String?,
          harga: harga is int ? harga.toDouble() : (harga as double),
          jumlah: jumlah is int ? jumlah : (jumlah as double).toInt(),
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
      transaksiList.add(transaksi);
    }

    return transaksiList;
  }

  Future<void> deleteFullTransaksi(int transaksiID) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Hapus data bridging pada detail_user_split yang terkait dengan transaksi ini.
      await txn.delete(
        'detail_user_split',
        where:
            'fk_detailID IN (SELECT DetailID FROM detail_transaksi WHERE fk_transaksiID = ?)',
        whereArgs: [transaksiID],
      );

      // 2. Hapus data detail_transaksi terkait.
      await txn.delete(
        'detail_transaksi',
        where: 'fk_transaksiID = ?',
        whereArgs: [transaksiID],
      );

      // 3. Hapus transaksi utama.
      await txn.delete(
        'transaksi',
        where: 'transaksiID = ?',
        whereArgs: [transaksiID],
      );
    });
  }
}

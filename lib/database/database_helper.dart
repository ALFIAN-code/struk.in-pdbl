import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:strukin/model/struk_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  static const _targetVersion = 4;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    debugPrint('▶️ [_initDatabase] called'); // 1️⃣
    final path = join(await getDatabasesPath(), 'strukin.db');
    final db = await openDatabase(
      path,
      version: _targetVersion,
      onCreate: (db, v) async {
        debugPrint('🆕 [onCreate] version $v'); // 2️⃣
        await _onCreate(db, v);
      },
      onUpgrade: (db, oldV, newV) async {
        debugPrint('⬆️ [onUpgrade] $oldV → $newV'); // 3️⃣
        await _onUpgrade(db, oldV, newV);
      },
    );
    debugPrint('✅ [_initDatabase] done, user_version=${await db.getVersion()}');
    return db;
  }

  // ini method manual migrate
  Future<void> manualMigrateIfNeeded() async {
    final db = await database;
    final current = await db.getVersion();
    if (current < _targetVersion) {
      debugPrint('▶️ Manual migrate DB $current → $_targetVersion');
      // panggil migrasi kamu
      await _onUpgrade(db, current, _targetVersion);
      // set PRAGMA user_version ke target
      await db.execute('PRAGMA user_version = $_targetVersion;');
      debugPrint('✅ After manual migrate, version=${await db.getVersion()}');
    } else {
      debugPrint('⏭ DB already at version $current');
    }
  }

  // Buat schema v2 untuk install baru
  Future<void> _onCreate(Database db, int version) async {
    // Tabel Usersplit
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Usersplit (
        UserID TEXT PRIMARY KEY,
        username TEXT,
        avatar TEXT
      );
    ''');

    // Tabel transaksi (v2)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaksi (
        transaksiID INTEGER PRIMARY KEY AUTOINCREMENT,
        create_at TEXT,
        image_path TEXT,
        store_name TEXT,
        struk_date TEXT,
        subtotal REAL,
        jumlah_participant INTEGER,
        pajak REAL,
        biaya_layanan REAL,
        diskon REAL,
        biaya_lainnya REAL,
        total REAL,
        category TEXT
      );
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
      );
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
      );
    ''');
  }

  // Migrasi schema dari v1 → v2
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('ALTER TABLE transaksi ADD COLUMN create_at TEXT;');
      await db.execute('ALTER TABLE transaksi ADD COLUMN diskon REAL;');
      await db.execute('ALTER TABLE transaksi ADD COLUMN biaya_lainnya REAL;');
      await db.execute('ALTER TABLE transaksi ADD COLUMN category TEXT;');
    }
  }

  Future<TransaksiModel> getTransaksiById(int transaksiID) async {
    final db = await database;
    final transaksiMaps = await db.query(
      'transaksi',
      where: 'transaksiID = ?',
      whereArgs: [transaksiID],
    );

    TransaksiModel transaksi = TransaksiModel.fromMap(transaksiMaps.single);

    final detailMaps = await db.query(
      'detail_transaksi',
      where: 'fk_transaksiID = ?',
      whereArgs: [transaksi.transaksiID],
    );

    List<DetailTransaksiModel> detailList = [];
    for (var dMap in detailMaps) {
      var harga = dMap['harga'];
      var jumlah = dMap['jumlah'];

      debugPrint('Detail Map: $dMap'); // Debugging line

      DetailTransaksiModel detail = DetailTransaksiModel(
        hargaSatuan: dMap['harga_satuan'] as int,
        detailID: dMap['DetailID'] as int,
        fkTransaksiID: dMap['fk_transaksiID'] as int,
        namaBarang: dMap['nama_barang'] as String?,
        harga: harga is int ? harga.toDouble() : (harga as double),
        jumlah: jumlah is int ? jumlah : (jumlah as double).toInt(),
      );

      final bridgingMaps = await db.query(
        'detail_user_split',
        where: 'fk_detailID = ?',
        whereArgs: [detail.detailID],
      );

      List<DetailUserSplitModel> bridgingList = [];
      for (var bMap in bridgingMaps) {
        DetailUserSplitModel bridging = DetailUserSplitModel.fromMap(bMap);
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

    transaksi = transaksi.copyWith(detailTransaksis: detailList);
    return transaksi;
  }

  Future<int> insertFullTransaksi(TransaksiModel transaksiModel) async {
    final db = await database;
    final now = DateTime.now();

    return await db.transaction((txn) async {
      final transaksiID = await txn.insert(
        'transaksi',
        TransaksiModel(
          transaksiID: transaksiModel.transaksiID,
          imagePath: transaksiModel.imagePath,
          storeName: transaksiModel.storeName,
          strukDate: transaksiModel.strukDate,
          subtotal: transaksiModel.subtotal,
          jumlahparticipant: transaksiModel.jumlahparticipant,
          pajak: transaksiModel.pajak,
          biayaLayanan: transaksiModel.biayaLayanan,
          diskon: transaksiModel.diskon,
          biayaLainnya: transaksiModel.biayaLainnya,
          total: transaksiModel.total,
          createAt:
              '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          category: transaksiModel.category,
        ).toMap(),
      );

      for (final detail in transaksiModel.detailTransaksis) {
        final detailID = await txn.insert(
          'detail_transaksi',
          DetailTransaksiModel(
            fkTransaksiID: transaksiID,
            namaBarang: detail.namaBarang,
            hargaSatuan: detail.hargaSatuan,
            harga: detail.harga,
            jumlah: detail.jumlah,
          ).toMap(),
        );

        for (final detailUser in detail.userSplits) {
          String userID;
          if (detailUser.user != null && detailUser.user!.userID != null) {
            await txn.insert(
              'Usersplit',
              UserSplitModel(
                userID: detailUser.user!.userID,
                username: detailUser.user!.username,
                avatar: detailUser.user!.avatar,
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            userID = detailUser.user!.userID!;
          } else {
            userID = detailUser.fkUserID!;
          }

          await txn.insert(
            'detail_user_split',
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

  Future<List<TransaksiModel>> getAllTransaksi() async {
    final db = await database;
    final transaksiMaps = await db.query('transaksi');
    if (transaksiMaps.isEmpty) return [];

    List<TransaksiModel> transaksiList = [];
    for (var transaksiMap in transaksiMaps) {
      TransaksiModel transaksi = TransaksiModel.fromMap(transaksiMap);

      final detailMaps = await db.query(
        'detail_transaksi',
        where: 'fk_transaksiID = ?',
        whereArgs: [transaksi.transaksiID],
      );

      List<DetailTransaksiModel> detailList = [];
      for (var dMap in detailMaps) {
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

        final bridgingMaps = await db.query(
          'detail_user_split',
          where: 'fk_detailID = ?',
          whereArgs: [detail.detailID],
        );

        List<DetailUserSplitModel> bridgingList = [];
        for (var bMap in bridgingMaps) {
          DetailUserSplitModel bridging = DetailUserSplitModel.fromMap(bMap);
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

      transaksi = transaksi.copyWith(detailTransaksis: detailList);
      transaksiList.add(transaksi);
    }
    return transaksiList;
  }

  Future<void> deleteFullTransaksi(int transaksiID) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'detail_user_split',
        where:
            'fk_detailID IN (SELECT DetailID FROM detail_transaksi WHERE fk_transaksiID = ?)',
        whereArgs: [transaksiID],
      );
      await txn.delete(
        'detail_transaksi',
        where: 'fk_transaksiID = ?',
        whereArgs: [transaksiID],
      );
      await txn.delete(
        'transaksi',
        where: 'transaksiID = ?',
        whereArgs: [transaksiID],
      );
    });
  }
}

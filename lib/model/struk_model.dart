class UserSplitModel {
  final int userID;
  final String? username;
  final String? avatar;

  UserSplitModel({required this.userID, this.username, this.avatar});

  factory UserSplitModel.fromMap(Map<String, dynamic> map) {
    return UserSplitModel(
      userID: map['UserID'],
      username: map['username'],
      avatar: map['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'UserID': userID, 'username': username, 'avatar': avatar};
  }
}

class DetailUserSplitModel {
  final int id;
  final int fkDetailID;
  final int fkUserID;
  final double? portion;

  // Relasi ke user
  final UserSplitModel? user;

  DetailUserSplitModel({
    required this.id,
    required this.fkDetailID,
    required this.fkUserID,
    this.portion,
    this.user,
  });

  factory DetailUserSplitModel.fromMap(Map<String, dynamic> map) {
    return DetailUserSplitModel(
      id: map['id'],
      fkDetailID: map['fk_detailID'],
      fkUserID: map['fk_userID'],
      portion: map['portion'] != null ? map['portion'].toDouble() : null,
      // user akan diisi belakangan
      user: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_detailID': fkDetailID,
      'fk_userID': fkUserID,
      'portion': portion,
    };
  }

  DetailUserSplitModel copyWith({UserSplitModel? user}) {
    return DetailUserSplitModel(
      id: id,
      fkDetailID: fkDetailID,
      fkUserID: fkUserID,
      portion: portion,
      user: user ?? this.user,
    );
  }
}

class DetailTransaksiModel {
  final int detailID;
  final int fkTransaksiID;
  final String? namaBarang;
  final double? harga;
  final int? jumlah;

  // Relasi bridging
  final List<DetailUserSplitModel> userSplits;

  DetailTransaksiModel({
    required this.detailID,
    required this.fkTransaksiID,
    this.namaBarang,
    this.harga,
    this.jumlah,
    this.userSplits = const [],
  });

  factory DetailTransaksiModel.fromMap(Map<String, dynamic> map) {
    return DetailTransaksiModel(
      detailID: map['DetailID'],
      fkTransaksiID: map['fk_transaksiID'],
      namaBarang: map['nama_barang'],
      harga: map['harga'] != null ? map['harga'].toDouble() : null,
      jumlah: map['jumlah'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'DetailID': detailID,
      'fk_transaksiID': fkTransaksiID,
      'nama_barang': namaBarang,
      'harga': harga,
      'jumlah': jumlah,
    };
  }

  DetailTransaksiModel copyWith({List<DetailUserSplitModel>? userSplits}) {
    return DetailTransaksiModel(
      detailID: detailID,
      fkTransaksiID: fkTransaksiID,
      namaBarang: namaBarang,
      harga: harga,
      jumlah: jumlah,
      userSplits: userSplits ?? this.userSplits,
    );
  }
}

class TransaksiModel {
  final int transaksiID;
  final String? imagePath;
  final String? storeName;
  final String? strukDate;
  final double? subtotal;
  final double? pajak;
  final double? biayaLayanan;
  final double? total;

  // Relasi ke model DetailTransaksi
  final List<DetailTransaksiModel> detailTransaksis;

  TransaksiModel({
    required this.transaksiID,
    this.imagePath,
    this.storeName,
    this.strukDate,
    this.subtotal,
    this.pajak,
    this.biayaLayanan,
    this.total,
    this.detailTransaksis = const [],
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      transaksiID: map['transaksiID'],
      imagePath: map['image_path'],
      storeName: map['store_name'],
      strukDate: map['struk_date'],
      subtotal: map['subtotal'] != null ? map['subtotal'].toDouble() : null,
      pajak: map['pajak'] != null ? map['pajak'].toDouble() : null,
      biayaLayanan:
          map['biaya_layanan'] != null ? map['biaya_layanan'].toDouble() : null,
      total: map['total'] != null ? map['total'].toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaksiID': transaksiID,
      'image_path': imagePath,
      'store_name': storeName,
      'struk_date': strukDate,
      'subtotal': subtotal,
      'pajak': pajak,
      'biaya_layanan': biayaLayanan,
      'total': total,
    };
  }

  TransaksiModel copyWith({List<DetailTransaksiModel>? detailTransaksis}) {
    return TransaksiModel(
      transaksiID: transaksiID,
      imagePath: imagePath,
      storeName: storeName,
      strukDate: strukDate,
      subtotal: subtotal,
      pajak: pajak,
      biayaLayanan: biayaLayanan,
      total: total,
      detailTransaksis: detailTransaksis ?? this.detailTransaksis,
    );
  }
}

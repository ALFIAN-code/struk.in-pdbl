import 'package:intl/intl.dart';
import 'package:strukin/controller/utils.dart';

class UserSplitModel {
  final String? userID;
  final String? username;
  final String? avatar;

  UserSplitModel({this.userID, this.username, this.avatar});

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
  final int? id;
  final int? fkDetailID;
  final String? fkUserID;
  final double? portion;
  final double? hargaPerParticipant;
  final UserSplitModel? user;

  DetailUserSplitModel({
    this.id,
    this.fkDetailID,
    this.fkUserID,
    this.portion,
    this.hargaPerParticipant,
    this.user,
  });

  factory DetailUserSplitModel.fromMap(Map<String, dynamic> map) {
    return DetailUserSplitModel(
      id: map['id'],
      fkDetailID: map['fk_detailID'],
      fkUserID: map['fk_userID'],
      portion: map['portion']?.toDouble(),
      hargaPerParticipant: map['harga_per_participant']?.toDouble(),
      user: null, // akan diisi nanti
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_detailID': fkDetailID,
      'fk_userID': fkUserID,
      'portion': portion,
      'harga_per_participant': hargaPerParticipant,
    };
  }

  DetailUserSplitModel copyWith({
    UserSplitModel? user,
    double? portion,
    double? hargaPerParticipant,
  }) {
    return DetailUserSplitModel(
      id: id,
      fkDetailID: fkDetailID,
      fkUserID: fkUserID,
      portion: portion ?? this.portion,
      hargaPerParticipant: hargaPerParticipant ?? this.hargaPerParticipant,
      user: user ?? this.user,
    );
  }
}

class DetailTransaksiModel {
  final int? detailID;
  final int? fkTransaksiID;
  final String? namaBarang;
  final double? harga;
  final int? hargaSatuan;
  final int? jumlah;

  // Relasi bridging
  final List<DetailUserSplitModel> userSplits;

  DetailTransaksiModel({
    this.detailID,
    this.fkTransaksiID,
    this.namaBarang,
    this.harga,
    this.hargaSatuan,
    this.jumlah,
    this.userSplits = const [],
  });

  factory DetailTransaksiModel.fromMap(Map<String, dynamic> map) {
    return DetailTransaksiModel(
      hargaSatuan: map['harga_satuan'],
      detailID: map['DetailID'],
      fkTransaksiID: map['fk_transaksiID'],
      namaBarang: map['nama_barang'],
      harga: map['harga']?.toDouble(),
      jumlah: map['jumlah'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'DetailID': detailID,
      'fk_transaksiID': fkTransaksiID,
      'nama_barang': namaBarang,
      'harga_satuan': hargaSatuan,
      'harga': harga,
      'jumlah': jumlah,
    };
  }

  DetailTransaksiModel copyWith({List<DetailUserSplitModel>? userSplits}) {
    return DetailTransaksiModel(
      hargaSatuan: hargaSatuan,
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
  final int? transaksiID;
  final String? imagePath;
  final String? storeName;
  final String? strukDate;
  final double? subtotal;
  final double? pajak;
  final double? biayaLayanan;
  final double? total;
  final int? jumlahparticipant;
  final double? diskon;
  final String? createAt;
  final String? category;
  final double? biayaLainnya;

  // Relasi ke model DetailTransaksi
  final List<DetailTransaksiModel> detailTransaksis;

  TransaksiModel({
    this.transaksiID,
    this.imagePath,
    this.storeName,
    this.strukDate,
    this.subtotal,
    this.pajak,
    this.biayaLayanan,
    this.total,
    this.jumlahparticipant,
    this.diskon,
    this.createAt,
    this.category,
    this.biayaLainnya,
    this.detailTransaksis = const [],
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      transaksiID: map['transaksiID'],
      imagePath: map['image_path'],
      storeName: map['store_name'],
      strukDate: map['struk_date'],
      jumlahparticipant: map['jumlah_participant'],
      subtotal: map['subtotal']?.toDouble(),
      pajak: map['pajak']?.toDouble(),
      biayaLayanan: map['biaya_layanan']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble(),
      diskon: map['diskon'] ?? 0.0,
      createAt:
          map['create_at'] ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime(1900, 1, 1, 1, 1)),
      category: map['category'] ?? 'Lainnya',
      biayaLainnya: map['biaya_lainnya'] ?? 0.0,
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
      'jumlah_participant': jumlahparticipant,
      'diskon': diskon,
      'create_at': createAt,
      'category': category,
      'biaya_lainnya': biayaLainnya,
    };
  }

  TransaksiModel copyWith({List<DetailTransaksiModel>? detailTransaksis}) {
    return TransaksiModel(
      jumlahparticipant: jumlahparticipant,
      transaksiID: transaksiID,
      imagePath: imagePath,
      storeName: storeName,
      strukDate: strukDate,
      subtotal: subtotal,
      pajak: pajak,
      biayaLayanan: biayaLayanan,
      total: total,
      detailTransaksis: detailTransaksis ?? this.detailTransaksis,
      diskon: diskon,
      createAt: createAt,
      category: category,
      biayaLainnya: biayaLainnya,
    );
  }
}

class DetailTransaksi {
  final int? id;
  final int fkUserID;
  final int fkTransaksiID;
  final String namaBarang;
  final double harga;
  final int jumlah;

  DetailTransaksi({
    this.id,
    required this.fkUserID,
    required this.fkTransaksiID,
    required this.namaBarang,
    required this.harga,
    required this.jumlah,
  });

  factory DetailTransaksi.fromMap(Map<String, dynamic> map) {
    return DetailTransaksi(
      id: map['DetailID'],
      fkUserID: map['fk_userID'],
      fkTransaksiID: map['fk_transaksiID'],
      namaBarang: map['nama_barang'],
      harga: map['harga'],
      jumlah: map['jumlah'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'DetailID': id,
      'fk_userID': fkUserID,
      'fk_transaksiID': fkTransaksiID,
      'nama_barang': namaBarang,
      'harga': harga,
      'jumlah': jumlah,
    };
  }
}
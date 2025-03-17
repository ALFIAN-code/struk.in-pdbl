class Transaksi {
  final int? id;
  final String imagePath;
  final String storeName;
  final String strukDate;
  final double subtotal;
  final double pajak;
  final double biayaLayanan;
  final double total;

  Transaksi({
    this.id,
    required this.imagePath,
    required this.storeName,
    required this.strukDate,
    required this.subtotal,
    required this.pajak,
    required this.biayaLayanan,
    required this.total,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['transaksiID'],
      imagePath: map['image_path'],
      storeName: map['store_name'],
      strukDate: map['struk_date'],
      subtotal: map['subtotal'],
      pajak: map['pajak'],
      biayaLayanan: map['biaya_layanan'],
      total: map['total'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaksiID': id,
      'image_path': imagePath,
      'store_name': storeName,
      'struk_date': strukDate,
      'subtotal': subtotal,
      'pajak': pajak,
      'biaya_layanan': biayaLayanan,
      'total': total,
    };
  }
}

import 'package:strukin/model/struk_model.dart';

/// Controller untuk mengelola tampilan detail struk
///
/// Bertanggung jawab untuk:
/// - Mengelompokkan item berdasarkan peserta
/// - Menghitung total pembayaran per peserta
class DetailpageController {
  /// Mengelompokkan item struk berdasarkan peserta
  ///
  /// [transaksi] - Data transaksi yang akan diproses
  ///
  /// Mengembalikan:
  /// - List<Map> berisi data pengelompokan per peserta
  ///   - username: Nama peserta
  ///   - avatar: Gambar profil peserta
  ///   - total_harga: Total yang harus dibayar peserta
  ///   - items: Daftar item yang dipilih peserta
  List<Map<String, dynamic>> groupItemsByUser(TransaksiModel transaksi) {
    // accumulator: userID → summary map
    final Map<String, Map<String, dynamic>> summary = {};

    for (final detail in transaksi.detailTransaksis) {
      // total porsi untuk item ini (misal: bakso 3 porsi)
      final totalPortion = detail.userSplits
          .map((s) => s.portion ?? 0)
          .fold<double>(0, (a, b) => a + b);

      // total harga item (harga sudah total; jika null, fallback ke hargaSatuan*jumlah)
      final detailTotalPrice =
          (detail.harga != null)
              ? detail.harga!
              : (detail.hargaSatuan! * (detail.jumlah ?? 1)).toDouble();

      for (final split in detail.userSplits) {
        final user = split.user;
        if (user == null) continue;

        // init entry kalau belum ada
        summary.putIfAbsent(
          user.userID!,
          () => {
            'username': user.username ?? 'Unknown',
            'avatar': user.avatar ?? '',
            'total_harga': 0.0,
            'items': <Map<String, dynamic>>[],
          },
        );
        final entry = summary[user.userID!]!;

        // hitung share berdasarkan porsi: (porsi_user / total_porsi) * detailTotalPrice
        final share =
            (totalPortion > 0)
                ? detailTotalPrice * (split.portion! / totalPortion)
                : 0.0;

        // tambahkan item ke list
        (entry['items'] as List).add({
          'nama_barang': detail.namaBarang ?? 'Unknown',
          'portion': split.portion ?? 0,
          'share_price': share,
        });

        // akumulasi total_harga
        entry['total_harga'] = (entry['total_harga'] as double) + share;
      }
    }

    return summary.values.toList();
  }
}

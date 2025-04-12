import 'package:get/get.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

/// Controller untuk mengelola tampilan hasil pembagian struk
///
/// Bertanggung jawab untuk:
/// - Mengelompokkan item berdasarkan peserta
/// - Menghitung total pembayaran per peserta
class ResultController extends GetxController {
  Rx<TransaksiModel?> transaksi = TransaksiModel().obs;

  var database = DatabaseHelper();

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
    Map<String, Map<String, dynamic>> userMap = {};

    for (var detail in transaksi.detailTransaksis) {
      for (var split in detail.userSplits) {
        String userId = split.user!.userID!;

        if (!userMap.containsKey(userId)) {
          userMap[userId] = {
            "username": split.user?.username,
            "avatar": split.user?.avatar ?? "",
            "total_harga": 0.0,
            "items": <Map<String, dynamic>>[],
          };
        }

        userMap[userId]!["total_harga"] += detail.harga! * split.portion!;
        userMap[userId]!["items"].add({
          "nama_barang": detail.namaBarang ?? "Unknown",
          "jumlah": detail.jumlah ?? 0,
          "harga_per_participant": detail.harga! * split.portion!,
        });
      }
    }

    return userMap.values.toList();
  }
}

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

  Future<void> getTransaksi(int idPeserta) async {
    transaksi.value = await database.getTransaksiById(idPeserta);
  }

  List<Map<String, dynamic>> groupItemsByUser(TransaksiModel transaksi) {
    Map<String, Map<String, dynamic>> userMap = {};

    for (var detail in transaksi.detailTransaksis) {
      for (var split in detail.userSplits) {
        String userId = split.fkUserID!;

        if (!userMap.containsKey(userId)) {
          userMap[userId] = {
            "username": split.user?.username,
            "avatar": split.user?.avatar,
            "total_harga": 0.0,
            "items": <Map<String, dynamic>>[],
          };
        }
        print('harga per participant2 = ${split.hargaPerParticipant}');
        userMap[userId]!["total_harga"] += detail.harga! * split.portion!;
        userMap[userId]!["items"].add({
          "nama_barang": detail.namaBarang ?? "Unknown",
          "jumlah": split.portion ?? 0.0,
          "harga_per_participant": split.hargaPerParticipant,
        });
      }
    }

    return userMap.values.toList();
  }
}

import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/database/remote_from_gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

/// Controller untuk mengelola logika pembagian struk
///
/// Bertanggung jawab untuk:
/// - Memproses gambar struk menjadi teks (OCR)
/// - Mengelola peserta pembagian struk
/// - Menyimpan data pembagian ke database
class SplitpageController extends GetxController {
  List<Item> selectedItem = [];
  Rx<List<int>> usedImages = Rx<List<int>>([]);
  var participants = Rx<List<Map<String, dynamic>>>([]);
  final Random _random = Random();
  var selectedIndex = 0.obs;
  Rx<StrukFromApi?> processedText = Rx<StrukFromApi?>(null);

  Rx<String?> ocrText = ''.obs;

  var isProcessing = false.obs;

  /*
  fungsi ini untuk memproses gambar struk yang diambil dari kamera
  dan mengirimkannya ke API untuk mendapatkan hasil OCR
  */
  /// Memproses gambar struk menggunakan API OCR
  ///
  /// [image] - File gambar struk
  /// [isConnected] - Status koneksi internet
  ///
  /// Mengembalikan:
  /// - StrukFromApi hasil pemrosesan
  /// - Null jika terjadi error
  Future<void> processReceiptImage(XFile image, bool isConnected) async {
    isProcessing.value = true;
    // try {

    if (isConnected == true) {
      final order = await processReceipt(geminiApi, image);
      processedText.value = order;
    }

    isProcessing.value = false;
  }

  /// Mendapatkan daftar peserta yang memilih item tertentu
  ///
  /// [item] - Item yang akan dicek
  ///
  /// Mengembalikan:
  /// - List<int> berisi index peserta yang memilih item
  List<int> getParticipantsWhoSelectedItem(Item item) {
    List<int> participantsWhoSelected = [];
    for (var i = 0; i < participants.value.length; i++) {
      if (participants.value[i]['selectedItems'].contains(item)) {
        participantsWhoSelected.add(i);
      }
    }
    return participantsWhoSelected;
  }

  /// Menambahkan peserta pertama secara otomatis
  ///
  /// Menambahkan peserta dengan gambar profil acak
  void addFirstParticipant() {
    if (participants.value.isEmpty) {
      int firstImage = _random.nextInt(58) + 1;
      usedImages.value.add(firstImage);

      participants.value.add({
        "id": Utils.generateCustomUUID(),
        "name": "USER 1",
        "image": "assets/images/profile/image$firstImage.png",
        "selected": false,
        "selectedItems": <Item>[],
      });
    }
  }

  /// Membersihkan pilihan menu untuk peserta tertentu
  ///
  /// [participantIndex] - Index peserta
  void clearSelectedMenu(int participantIndex) {
    selectedItem = participants.value[participantIndex]['selectedItems'];
    update();
  }

  /// Menangani pemilihan multiple item oleh peserta
  ///
  /// [item] - Item yang dipilih
  /// [participantIndex] - Index peserta
  void doMultiSelection(Item item, int participantIndex) {
    if (selectedItem.contains(item)) {
      participants.value[participantIndex]['selectedItems'].remove(item);
      selectedItem.remove(item);
    } else {
      participants.value[participantIndex]['selectedItems'].add(item);
      selectedItem.add(item);
    }
    update();
  }

  /// Menambahkan peserta baru dengan gambar profil acak
  ///
  /// Gambar profil dipilih secara unik dari daftar yang tersedia
  void addParticipant() {
    if (usedImages.value.length >= 58) return;

    int newImage;
    do {
      newImage = _random.nextInt(58) + 1;
    } while (usedImages.value.contains(newImage));

    usedImages.value.add(newImage);

    participants.value.add({
      "id": Utils.generateCustomUUID(),
      "name": "USER ${participants.value.length + 1}",
      "image": "assets/images/profile/image$newImage.png",
      "selected": false,
      "selectedItems": <Item>[],
    });
    update();
  }

  /// Memilih profil peserta tertentu
  ///
  /// [index] - Index peserta yang dipilih
  void selectProfile(int index) {
    for (var participant in participants.value) {
      participant["selected"] = false;
    }
    participants.value[index]["selected"] = true;
    update();
  }

  /// Menghapus peserta dari daftar
  ///
  /// [index] - Index peserta yang akan dihapus
  void deleteParticipant(int index) {
    int removedImage = int.parse(
      participants.value[index]["image"]
          .replaceAll("assets/images/profile/image", "")
          .replaceAll(".png", ""),
    );
    usedImages.value.remove(removedImage);
    participants.value.removeAt(index);
    update();
  }

  /// Menyimpan data pembagian struk ke database
  ///
  /// [imgpath] - Path gambar struk
  ///
  /// Mengembalikan:
  /// - TransaksiModel yang berhasil disimpan
  /// - Null jika terjadi error
  Future<TransaksiModel?> addDataToDatabase(String imgpath) async {
    // Pastikan data hasil OCR dan parsing (processedText) sudah tersedia
    if (processedText.value == null) {
      print("Data struk belum tersedia.");
      return null;
    }

    var customID = Utils.generateCustomUUID();

    // Ambil data transaksi utama dari hasil OCR (processedText)
    final strukData = processedText.value!;

    // Kumpulkan semua item unik yang telah dipilih oleh peserta
    Set<Item> uniqueItems = {};
    for (var participant in participants.value) {
      List<Item> selectedItems = participant['selectedItems'];
      uniqueItems.addAll(selectedItems);
    }

    List<DetailTransaksiModel> detailList = [];

    // Untuk setiap item, cari peserta yang memilih item tersebut
    for (var item in uniqueItems) {
      List<int> participantIndices = getParticipantsWhoSelectedItem(item);
      // Misalnya, porsi tiap peserta adalah 1 dibagi jumlah peserta yang memilih item tersebut
      double portion =
          participantIndices.isNotEmpty ? 1.0 / participantIndices.length : 1.0;

      List<DetailUserSplitModel> userSplits = [];
      for (var index in participantIndices) {
        var participant = participants.value[index];
        // Buat model Usersplit dari data peserta
        UserSplitModel user = UserSplitModel(
          // 0 sebagai tanda user baru (akan di-auto increment saat insert)
          userID: participant['id'],
          username: participant['name'],
          avatar: participant['image'],
        );
        userSplits.add(
          DetailUserSplitModel(
            // akan di-set oleh proses insert user
            portion: portion,
            // hargaPerParticipant akan dihitung di dalam fungsi insertFullTransaksi
            user: user,
          ),
        );
      }

      // Buat detail transaksi untuk item ini
      DetailTransaksiModel detail = DetailTransaksiModel(
        hargaSatuan: item.unitPrice,
        namaBarang: item.name,
        harga: item.price!.toDouble(),
        jumlah: item.quantity,
        userSplits: userSplits,
      );

      detailList.add(detail);
    }

    // Buat objek TransaksiModel dengan data dari processedText dan list detail di atas
    TransaksiModel transaksi = TransaksiModel(
      // transaksiID: customID,
      imagePath: imgpath, // bisa diisi dengan path gambar jika diperlukan
      storeName: strukData.businessName,
      strukDate: strukData.date,
      subtotal: strukData.subtotal?.toDouble() ?? 0,
      pajak: strukData.tax?.toDouble() ?? 0,
      biayaLayanan: 0,
      total: strukData.total?.toDouble() ?? 0,
      detailTransaksis: detailList,
      jumlahparticipant: participants.value.length,
    );
    await DatabaseHelper().insertFullTransaksi(transaksi);
    return transaksi;
  }
}

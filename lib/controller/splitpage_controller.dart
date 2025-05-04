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
  StrukFromApi? processedTextBackup;
  Rx<String?> ocrText = ''.obs;
  var isProcessing = true.obs;
  var includePajak = false.obs;

  //variable ini akan ditambah setiap menambah participant, untuk menghindari duplikasi
  int participantIncrement = 1;

  /// Reset semua state ke kondisi awal
  void resetState() {
    selectedItem.clear();
    usedImages.value = [];
    participants.value = [];
    selectedIndex.value = 0;
    processedText.value = null;
    processedTextBackup = null;
    ocrText.value = '';
    isProcessing.value = false;
    includePajak.value = false;
    participantIncrement = 1;

    print('state split page bersih');
  }

  @override
  void onClose() {
    resetState();
    super.onClose();
  }

  void updateData(StrukFromApi transaksi) {
    processedText.value = transaksi;
    update();
  }

  //Fungsi untuk mendapatkan persentase pajak dari harga pajak dan total harga
  double getTaxRatio() {
    final tax = processedText.value?.tax;
    final total = processedText.value?.subtotal;

    if (tax != null && total != null && total != 0) {
      return ((tax / total) * 100);
    } else {
      return 0; // fallback default, bisa juga null kalau kamu ingin
    }
  }

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
    Future.microtask(() => isProcessing.value = true);
    // try {

    if (isConnected == true) {
      final order = await processReceipt(geminiApi, image);
      processedText.value = order;
      processedTextBackup = StrukFromApi(
        isStruk: processedText.value?.isStruk,
        invoiceNumber: processedText.value?.invoiceNumber,
        businessName: processedText.value?.businessName,
        date: processedText.value?.date,
        subtotal: processedText.value?.subtotal,
        tax: processedText.value?.tax,
        total: processedText.value?.total,
        items:
            processedText.value?.items?.map((item) => item.copyWith()).toList(),
      );
    }
    isProcessing.value = false;
  }

  /// Mendapatkan daftar peserta yang memilih item tertentu
  ///
  /// [item] - Item yang akan dicek
  ///
  /// Mengembalikan:
  List<int> getParticipantsWhoSelectedItem(Item item) {
    List<int> participantsWhoSelected = [];
    for (var i = 0; i < participants.value.length; i++) {
      List<Map<String, dynamic>> selectedItems =
          participants.value[i]['selectedItems'];
      bool itemFound = selectedItems.any(
        (entry) => (entry['item'] as Item).id == item.id,
      );
      if (itemFound) {
        participantsWhoSelected.add(i);
      }
    }
    return participantsWhoSelected;
  }

  /// Membersihkan pilihan menu untuk peserta tertentu
  ///
  /// [participantIndex] - Index peserta
  void clearSelectedMenu(int participantIndex) {
    selectedItem.clear();
    print("clear Selected = $participantIndex");
    for (var e
        in (participants.value[participantIndex]['selectedItems']
            as List<Map<String, dynamic>>)) {
      selectedItem.add(e['item']);
    }
    update();
  }

  /// Menangani pemilihan multiple item oleh peserta
  ///
  /// [item] - Item yang dipilih
  /// [participantIndex] - Index peserta
  void doMultiSelection(Item item, int participantIndex) {
    if (selectedItem.contains(item)) {
      (participants.value[participantIndex]['selectedItems']
              as List<Map<String, dynamic>>)
          .removeWhere((element) => (element['item'] as Item).id == item.id);
      selectedItem.remove(item);
    } else {
      participants.value[participantIndex]['selectedItems'].add({
        'quantity': 1,
        'item': item,
      });
      selectedItem.add(item);
    }
    update();
  }

  /// Mengatur Kuantitas
  ///
  /// [item] - Item yang akan diatur kuantitasnya
  ///
  void controlQuantity({
    required Item item,
    required bool isIncrement,
    required int participantIndex,
  }) {
    List<Map<String, dynamic>> items =
        participants.value[participantIndex]['selectedItems'];

    for (var i = 0; i < items.length; i++) {
      if ((items[i]['item'] as Item).id == item.id) {
        int quantity =
            participants
                .value[participantIndex]['selectedItems'][i]['quantity'];

        if (quantity >= 1 && isIncrement) {
          quantity += 1;
        }
        if (quantity > 1 && !isIncrement) {
          quantity -= 1;
        }
        participants.value[participantIndex]['selectedItems'][i]['quantity'] =
            quantity;

        print(
          participants.value[participantIndex]['selectedItems'][i]['quantity'],
        );
        update();
      }
    }
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

    // Tentukan nama user
    participantIncrement = participants.value.length + 1;

    participants.value.add({
      "id": Utils.generateCustomStringID(),
      "name": "USER $participantIncrement",
      "image": "assets/images/profile/image$newImage.png",
      "selected": false,
      "selectedItems": <Map<String, dynamic>>[],
    });
    clearSelectedMenu(participants.value.length - 1);
    selectedIndex.value = participants.value.length - 1;
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
  Future<TransaksiModel?> addDataToDatabase2(String imgpath) async {
    if (processedText.value == null) {
      print("Data struk belum tersedia.");
      return null;
    }
    final strukData = processedText.value!;

    var tax = getTaxRatio();

    Set<Item> uniqueItems = {};
    for (var i = 0; i < participants.value.length; i++) {
      List<Map<String, dynamic>> selectedItems =
          participants.value[i]['selectedItems'];
      for (var element in selectedItems) {
        uniqueItems.add(element['item']);
      }
      // uniqueItems.addAll(selectedItems);
    }

    List<DetailTransaksiModel> detailList = [];
    for (var item in uniqueItems) {
      List<int> participantIndices = getParticipantsWhoSelectedItem(item);
      print('tax ratio = ${tax / 100}');
      var unitTax = (item.unitPrice! * tax / 100).round();

      var totalQuantity = 0;
      for (var i = 0; i < participants.value.length; i++) {
        List<Map<String, dynamic>> dump =
            participants.value[i]['selectedItems'];

        for (var i = 0; i < dump.length; i++) {
          if ((dump[i]['item'] as Item).id == item.id) {
            totalQuantity += dump[i]['quantity'] as int;
          }
        }
      }

      List<DetailUserSplitModel> userSplits = [];
      for (var index in participantIndices) {
        var participant = participants.value[index];
        int participantQuantity = 0;

        for (var element
            in (participants.value[index]['selectedItems']
                as List<Map<String, dynamic>>)) {
          if ((element['item'] as Item).id == item.id) {
            participantQuantity = element['quantity'];
          }
        }

        var hargaPerParticipant =
            (participantQuantity / totalQuantity) *
            ((includePajak.value)
                ? ((unitTax + item.unitPrice!) * item.quantity!)
                : item.price!);
        print(unitTax);
        print(
          '  ${participants.value[index]['name']}  $participantQuantity $totalQuantity',
        );

        print(
          '${item.name}  ${participants.value[index]['name']}  $hargaPerParticipant',
        );

        UserSplitModel user = UserSplitModel(
          userID: participant['id'],
          username: participant['name'],
          avatar: participant['image'],
        );

        DetailUserSplitModel detailUserSplit = DetailUserSplitModel(
          hargaPerParticipant: hargaPerParticipant,
          portion: participantQuantity.toDouble(),
          user: user,
        );

        userSplits.add(detailUserSplit);
      }
      print(
        userSplits.map(
          (e) => print('harga per participant = ${e.hargaPerParticipant}'),
        ),
      );

      DetailTransaksiModel detail = DetailTransaksiModel(
        hargaSatuan:
            (includePajak.value) ? unitTax + item.unitPrice! : item.unitPrice,
        namaBarang: item.name,
        harga:
            (includePajak.value)
                ? ((unitTax + item.unitPrice!) * item.quantity!).toDouble()
                : item.price!.toDouble(),
        jumlah: item.quantity,
        userSplits: userSplits,
      );
      detailList.add(detail);
    }
    TransaksiModel transaksi = TransaksiModel(
      imagePath: imgpath,
      storeName: strukData.businessName,
      strukDate: strukData.date,
      transaksiID: Utils.generateCustomIntID(),
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

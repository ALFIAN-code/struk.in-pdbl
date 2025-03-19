import 'dart:collection';
import 'dart:math';

import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/database/remote_from_gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';
import 'package:strukin/model/transaksi.dart';
import 'package:strukin/model/usersplit.dart';

class SplitpageController extends GetxController {
  List<Item> selectedItem = [];

  final List<int> _availableImages = List.generate(39, (index) => index + 1);
  Rx<List<int>> usedImages = Rx<List<int>>([]);
  var participants = Rx<List<Map<String, dynamic>>>([]);
  final Random _random = Random();
  var selectedIndex = 0.obs;
  Rx<StrukFromApi?> processedText = Rx<StrukFromApi?>(null);

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Rx<String?> ocrText = ''.obs;

  var isProcessing = false.obs;

  final List<String> _categories = [
    'Kuliner',
    'Belanja',
    'Transportasi',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Elektronik',
    'Pakaian',
    'Otomotif',
    'lainnya',
  ];

  Future<void> processReceiptImage(XFile image) async {
    isProcessing.value = true;

    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.text.isEmpty) {
      isProcessing.value = false;
      return;
    }

    final order = await processReceipt(
      recognizedText.text,
      geminiApi,
      _categories,
    );

    ocrText.value = recognizedText.text;
    processedText.value = order;

    isProcessing.value = false;
  }

  List<int> getParticipantsWhoSelectedItem(Item item) {
    List<int> participantsWhoSelected = [];
    for (var i = 0; i < participants.value.length; i++) {
      if (participants.value[i]['selectedItems'].contains(item)) {
        participantsWhoSelected.add(i);
      }
    }
    return participantsWhoSelected;
  }

  void addFirstParticipant() {
    if (participants.value.isEmpty) {
      int firstImage = _random.nextInt(39) + 1;
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

  void clearSelectedMenu(int participantIndex) {
    selectedItem = participants.value[participantIndex]['selectedItems'];
    update();
  }

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

  void addParticipant() {
    if (usedImages.value.length >= 39) return;

    int newImage;
    do {
      newImage = _random.nextInt(39) + 1;
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

  void selectProfile(int index) {
    for (var participant in participants.value) {
      participant["selected"] = false;
    }
    participants.value[index]["selected"] = true;
    update();
  }

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

  Future<void> addDataToDatabase() async {
    // Pastikan data hasil OCR dan parsing (processedText) sudah tersedia
    if (processedText.value == null) {
      print("Data struk belum tersedia.");
      return;
    }

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
      // Misal, bagi secara sama: porsi = 1 dibagi jumlah peserta yang memilih item tersebut
      double portion =
          participantIndices.isNotEmpty ? 1.0 / participantIndices.length : 1.0;

      List<DetailUserSplitModel> userSplits = [];
      for (var index in participantIndices) {
        var participant = participants.value[index];
        // Buat model Usersplit dari data peserta
        UserSplitModel user = UserSplitModel(
          userID:
              0, // 0 sebagai tanda user baru (akan di-auto increment saat insert)
          username: participant['name'],
          avatar: participant['image'],
        );
        userSplits.add(
          DetailUserSplitModel(
            id: 0, // auto increment
            fkDetailID: 0, // akan di-set oleh proses insert detail
            fkUserID: 0, // akan di-set oleh proses insert user
            portion: portion,
            user: user,
          ),
        );
      }

      // Buat detail transaksi untuk item ini
      DetailTransaksiModel detail = DetailTransaksiModel(
        detailID: 0, // auto increment
        fkTransaksiID: 0, // akan di-set oleh insert transaksi
        namaBarang: item.name,
        harga: item.price,
        jumlah: item.quantity,
        userSplits: userSplits,
      );

      detailList.add(detail);
    }

    // Buat objek TransaksiModel dengan data dari processedText dan list detail di atas
    TransaksiModel transaksi = TransaksiModel(
      transaksiID: 0, // auto increment
      imagePath:
          "", // misalnya bisa diisi dengan path gambar atau dibiarkan kosong
      storeName: strukData.businessName,
      strukDate: strukData.date,
      subtotal: strukData.subtotal?.toDouble() ?? 0,
      pajak: strukData.tax?.toDouble() ?? 0,
      biayaLayanan: 0,
      total: strukData.total?.toDouble() ?? 0,
      detailTransaksis: detailList,
    );

    // Lakukan insert ke database menggunakan DatabaseHelper (pastikan method insertFullTransaksi sudah ada)
    try {
      int newTransaksiID = await DatabaseHelper().insertFullTransaksi(
        transaksi,
      );
      print("Berhasil menambahkan transaksi dengan ID: $newTransaksiID");
    } catch (e) {
      print("Terjadi error saat insert data: $e");
    }
  }
}

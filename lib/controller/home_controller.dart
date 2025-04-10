import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

import 'package:path/path.dart' as p;

import 'package:flutter_image_compress/flutter_image_compress.dart';

class StrukController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var fullStrukList = <TransaksiModel>[].obs;

  Rx<XFile?> receiptImage = Rx<XFile?>(null);

  var database = DatabaseHelper();
  // var listStruk = <Transaksi>[];
  Rx<List<TransaksiModel>> strukList = Rx<List<TransaksiModel>>([]);

  Future<void> deleteStruk(int id) async {
    await database.deleteFullTransaksi(id);
    await getAllStruk(); // Refresh the list after deletion
  }

  // Fungsi search untuk filter list transaksi
  void searchStruk(String query) {
    if (query.isEmpty) {
      strukList.value = fullStrukList;
    } else {
      strukList.value =
          fullStrukList.where((transaksi) {
            return transaksi.storeName?.toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                false;
          }).toList();
    }
  }

  Future<void> getAllStruk() async {
    fullStrukList.value = await database.getAllTransaksi();
    strukList.value = fullStrukList;
  }

  Future<String?> normalizeImage(String inputPath, {int quality = 80}) async {
    try {
      // Baca ekstensi lama, ganti jadi .jpg
      final fileNameJpg = p.setExtension(p.basename(inputPath), '.jpg');
      // Dapatkan direktori aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final outputPath = p.join(appDir.path, fileNameJpg);

      // Lakukan kompresi & konversi ke JPEG
      final result = await FlutterImageCompress.compressAndGetFile(
        inputPath,
        outputPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      return result?.path;
    } catch (e) {
      // Tangani error (misal file corrupt)
      print('Error normalizing image: $e');
      return null;
    }
  }

  Future<XFile?> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      // Normalisasi (convert + copy) ke JPEG di app dir
      final normalizedPath = await normalizeImage(pickedImage.path);
      return normalizedPath != null
          ? XFile(normalizedPath)
          : null; // Kembalikan file yang sudah dinormalisasi
    } else {
      return null;
    }
  }

  Future<XFile?> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Normalisasi (convert + copy) ke JPEG di app dir
      final normalizedPath = await normalizeImage(pickedImage.path);
      return normalizedPath != null
          ? XFile(normalizedPath)
          : null; // Kembalikan file yang sudah dinormalisasi
    } else {
      return null;
    }
  }
}

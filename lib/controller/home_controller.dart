import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

import 'package:path/path.dart' as p;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Controller untuk mengelola logika bisnis terkait struk
///
/// Bertanggung jawab untuk:
/// - Mengambil dan menyimpan gambar struk (dari kamera/galeri)
/// - Mengelola data struk di database
/// - Melakukan pencarian dan filter struk
class HomepageController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var fullStrukList = <TransaksiModel>[].obs;

  Rx<XFile?> receiptImage = Rx<XFile?>(null);

  var database = DatabaseHelper();
  Rx<List<TransaksiModel>> strukList = Rx<List<TransaksiModel>>([]);

  /// Menghapus struk dari database berdasarkan ID
  ///
  /// [id] - ID struk yang akan dihapus
  ///
  /// Melempar exception jika terjadi error saat menghapus
  Future<void> deleteStruk(int id) async {
    await database.deleteFullTransaksi(id);
    await getAllStruk(); // Refresh the list after deletion
  }

  // Fungsi search untuk filter list transaksi
  /// Mencari struk berdasarkan nama toko
  ///
  /// [query] - Kata kunci pencarian
  ///
  /// Memperbarui strukList dengan hasil pencarian
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

  /// Mengambil semua data struk dari database
  ///
  /// Mengembalikan:
  /// - List<TransaksiModel> yang berisi semua struk
  /// - Melempar exception jika terjadi error
  Future<void> getAllStruk() async {
    fullStrukList.value = await database.getAllTransaksi();
    strukList.value = fullStrukList.reversed.toList();
  }

  /// Normalisasi gambar struk dengan kompresi dan konversi format
  ///
  /// [inputPath] - Path gambar asli
  /// [quality] - Kualitas kompresi (0-100)
  ///
  /// Mengembalikan:
  /// - Path gambar yang sudah dinormalisasi
  /// - Null jika terjadi error
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

  /// Mengambil gambar struk dari kamera
  ///
  /// Mengembalikan:
  /// - XFile gambar yang sudah dinormalisasi
  /// - Null jika pengambilan gambar dibatalkan
  Future<XFile?> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      // Salin ke direktori sementara dulu
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final copiedFile = await File(pickedImage.path).copy(tempFile.path);

      // Normalisasi (convert/copy jpeg)
      final normalizedPath = await normalizeImage(copiedFile.path);

      return normalizedPath != null ? XFile(normalizedPath) : null;
    } else {
      return null;
    }
  }

  /// Mengambil gambar struk dari galeri
  ///
  /// Mengembalikan:
  /// - XFile gambar yang sudah dinormalisasi
  /// - Null jika pemilihan gambar dibatalkan
  Future<XFile?> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Salin ke direktori sementara dulu
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final copiedFile = await File(pickedImage.path).copy(tempFile.path);

      // Normalisasi (convert/copy jpeg)
      final normalizedPath = await normalizeImage(copiedFile.path);

      return normalizedPath != null ? XFile(normalizedPath) : null;
    } else {
      return null;
    }
  }
}

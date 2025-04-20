import 'dart:math';

import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:intl/intl.dart';

/// Kumpulan fungsi utilitas untuk aplikasi Struk.in
///
/// Berisi fungsi-fungsi untuk:
/// - Format mata uang
/// - Generate ID unik
/// - Konversi dan validasi gambar
class Utils {
  /// Memformat angka menjadi string mata uang
  ///
  /// [amount] - Jumlah yang akan diformat
  ///
  /// Mengembalikan:
  /// - String berformat mata uang (contoh: "IDR 50,000")
  static String formatCurrency(int amount, {bool withSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: (withSymbol) ? 'IDR ' : '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Membuat ID unik acak
  ///
  /// Mengembalikan:
  /// - String acak sepanjang 8 karakter
  static String generateCustomStringID() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static int generateCustomIntID() {
    final random = Random();
    final id = random.nextInt(90000000) + 10000000; // 10000000–99999999
    return id;
  }

  /// Mengkonversi gambar ke format PNG
  ///
  /// [imageFile] - File gambar yang akan dikonversi
  ///
  /// Mengembalikan:
  /// - File gambar dalam format PNG
  /// - Null jika konversi gagal
  static Future<File?> convertImageToPng(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) return null;

    final convertedBytes = img.encodePng(decodedImage);
    final newFile = File('${imageFile.path}.png');
    await newFile.writeAsBytes(convertedBytes);

    return newFile;
  }

  /// Memvalidasi apakah file adalah gambar yang valid
  ///
  /// [path] - Path file gambar
  ///
  /// Mengembalikan:
  /// - True jika file adalah gambar valid
  /// - False jika tidak valid atau file tidak ada
  static bool isValidImage(String path) {
    final file = File(path);
    if (!file.existsSync()) return false;

    final bytes = file.readAsBytesSync();
    final decodedImage = img.decodeImage(bytes);
    return decodedImage != null;
  }

  /// Handler untuk memproses gambar
  ///
  /// [imagePath] - Path gambar yang akan diproses
  ///
  /// Mengembalikan:
  /// - File gambar yang sudah diproses
  /// - Null jika pemrosesan gagal
  static Future<File?> imagehandler(String imagePath) async {
    File? imageFile = File(imagePath);
    var convertedImage = await convertImageToPng(imageFile);

    return convertedImage;
  }
}

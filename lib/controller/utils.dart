import 'dart:math';

import 'dart:io';
import 'package:flutter/material.dart';
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
  static String formatCurrencyCompact(int amount, {bool withSymbol = true}) {
    if (amount >= 100000) {
      // Gunakan compact format (misalnya 120K, 5JT)
      final compactFormatter = NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: withSymbol ? 'IDR ' : '',
        decimalDigits: 0,
      );
      return compactFormatter.format(amount);
    } else {
      // Gunakan format biasa (misalnya IDR 50.000)
      final regularFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: withSymbol ? 'IDR ' : '',
        decimalDigits: 0,
      );
      return regularFormatter.format(amount);
    }
  }

  static String formatCurrency(int amount, {bool withSymbol = true}) {
    if (amount <= 999_999_999) {
      // Gunakan format biasa (misalnya IDR 50.000)
      final regularFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: withSymbol ? 'IDR ' : '',
        decimalDigits: 0,
      );
      return regularFormatter.format(amount);
    } else {
      final compactFormatter = NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: withSymbol ? 'IDR ' : '',
        decimalDigits: 0,
      );
      return compactFormatter.format(amount);
    }
  }

  static String formatDigit(int amount) {
    final compactFormatter = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return compactFormatter.format(amount);
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

  static int getRandomNumberExcept(int min, int max, int except) {
    final random = Random();
    int result;

    do {
      result = min + random.nextInt(max - min + 1);
    } while (result == except);

    return result;
  }

  static String formatDateFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '------';
    }

    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy HH:mm').format(date);
    } catch (e) {
      // Jika parsing gagal (format salah), tetap tampilkan '------'
      return '------';
    }
  }

  // Fungsi terpisah untuk normalize format tanggal
  static DateTime parseCustomDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(1900);

    try {
      // Coba parse format standar dulu
      DateTime? parsed = DateTime.tryParse(dateStr);
      if (parsed != null) return parsed;

      // Jika gagal, coba normalize format custom seperti "2025-5-27 15:8"
      String normalized = dateStr;

      // Split tanggal dan waktu
      List<String> parts = normalized.split(' ');
      if (parts.length == 2) {
        String datePart = parts[0];
        String timePart = parts[1];

        // Normalize date part (tambah 0 di depan jika perlu)
        List<String> dateParts = datePart.split('-');
        if (dateParts.length == 3) {
          String year = dateParts[0];
          String month = dateParts[1].padLeft(2, '0');
          String day = dateParts[2].padLeft(2, '0');
          datePart = '$year-$month-$day';
        }

        // Normalize time part (tambah 0 di depan untuk menit/detik jika perlu)
        List<String> timeParts = timePart.split(':');
        if (timeParts.length >= 2) {
          String hour = timeParts[0].padLeft(2, '0');
          String minute = timeParts[1].padLeft(2, '0');
          String second =
              timeParts.length > 2 ? timeParts[2].padLeft(2, '0') : '00';
          timePart = '$hour:$minute:$second';
        }

        normalized = '$datePart $timePart';
      }

      return DateTime.tryParse(normalized) ?? DateTime(1900);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return DateTime(1900);
    }
  }

  static String randomQuotes() {
    List<String> funnyQuotes = [
      'Ketika kamu malas, bukan berarti kamu rajin.',
      'Andai dompet bisa diisi ulang secara gratis.',
      'Istiqomah itu berat, yang ringan mah istirahat.',
      'Selalu ikuti kata hatimu. Tapi ingat, bawalah otakmu juga.',
      'Carilah uang, karena dia tak punya kaki untuk datang padamu.',
      'Saat semua pekerjaan dirasa makin tidak menyenangkan, ingatlah akan cicilan.',
      'Cinta tak mengenal warna kulit, tapi mengenal warna duit.',
      'Jika kita memimpikan seseorang, itu tandanya kita sedang tidur.',
      'Jadilah seperti bulu ketiak, meskipun hidup terhimpit, terjepit, dan tertekan, tetapi tetap tumbuh subur.',
      'Kenapa kau melakukannya hari ini jika bisa melakukannya besok?',
      'PR-ku seperti mantan, banyak yang belum selesai.',
      'Status pendidikan: Masih dibiayai karma baik orang tua.',
      'Nilai UTS seperti sinetron, banyak dramanya.',
      'IPK-ku seperti sinyal HP, kadang naik kadang hilang.',
      'Skripsi adalah jalan ninjaku.',
      'Wisuda adalah konser yang tiketnya paling mahal.',
      'Semester tua tapi masih muda di hati.',
      'Belajar adalah ibadah, tapi kenapa rasanya seperti azab?',
      'Tugas numpuk seperti cucian weekend.',

      'Sakit hati dan sakit gigi itu sama-sama berawal dari yang manis.',
      'Kunci sukses suatu hubungan adalah selalu membersihkan history chat.',
      'Anda sopan kami curiga.',
      'Manusia menciptakan ponsel. Ponsel makin pintar. Manusia tidak.',

      'Kirain udah bedug magrib, nggak tahunya tetangga lagi jemur kasur.',

      'Ingat, di balik kesulitan ada kesulitan yang lain.',
      'Di mana ada kelebihan, di situ ada kembalian.',
    ];

    final random = Random();
    return funnyQuotes[random.nextInt(funnyQuotes.length)];
  }

  static double getPercentage({required int bagian, required int total}) {
    if (total != 0) {
      return ((bagian / total) * 100);
    } else {
      return 0;
    }
  }
}

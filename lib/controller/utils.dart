import 'dart:math';

import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:intl/intl.dart';

class Utils {
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String generateCustomUUID() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static Future<File?> convertImageToPng(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) return null;

    final convertedBytes = img.encodePng(decodedImage);
    final newFile = File('${imageFile.path}.png');
    await newFile.writeAsBytes(convertedBytes);

    return newFile;
  }

  static bool isValidImage(String path) {
    final file = File(path);
    if (!file.existsSync()) return false;

    final bytes = file.readAsBytesSync();
    final decodedImage = img.decodeImage(bytes);
    return decodedImage != null;
  }

  static Future<File?> imagehandler(String imagePath) async {
    File? imageFile = File(imagePath);
    var convertedImage = await convertImageToPng(imageFile);

    return convertedImage;
  }
}

import 'dart:math';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Utils {
  static Future<bool> checkInternetConnection() async {
    bool isConnected = await InternetConnection().hasInternetAccess;
    return isConnected;
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
}

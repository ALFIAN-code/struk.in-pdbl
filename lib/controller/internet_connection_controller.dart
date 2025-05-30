import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Controller untuk memantau status koneksi internet
///
/// Bertanggung jawab untuk:
/// - Memeriksa ketersediaan koneksi internet
/// - Memberi notifikasi realtime saat status koneksi berubah
class ConnectionController extends GetxController {
  // Observable untuk status koneksi
  RxBool hasConnection = true.obs;
  var internetConnection = InternetConnectionChecker.createInstance(
    checkInterval: Duration(seconds: 5),
  );

  /// Inisialisasi controller
  ///
  /// Memulai pemantauan status koneksi internet
  @override
  void onInit() {
    super.onInit();
    // Pantau status koneksi secara realtime
    internetConnection.onStatusChange.listen((status) {
      hasConnection.value = status == InternetConnectionStatus.connected;
      debugPrint('Koneksi internet: ${hasConnection.value}');
    });
  }
}

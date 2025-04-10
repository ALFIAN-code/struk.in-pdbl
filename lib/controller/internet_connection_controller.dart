import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionController extends GetxController {
  // Observable untuk status koneksi
  RxBool hasConnection = true.obs;
  var internetConnection = InternetConnectionChecker.createInstance(
    checkInterval: Duration(seconds: 5),
  );

  @override
  void onInit() {
    super.onInit();
    // Pantau status koneksi secara realtime
    internetConnection.onStatusChange.listen((status) {
      hasConnection.value = status == InternetConnectionStatus.connected;
      print('Koneksi internet: ${hasConnection.value}');
    });
  }
}

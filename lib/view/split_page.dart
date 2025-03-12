import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strukin/controller/struk_controller.dart';
import 'package:strukin/controller/utils.dart';

class SplitPage extends StatelessWidget {
  SplitPage({super.key});

  final controller = Get.find<StrukController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<StrukController>(
        init: StrukController(),
        initState: (state) async {
          controller.processReceiptImage();
          // var connection = await Utils.checkInternetConnection();
          // print('connection = $connection');
          // if (connection) {
          //   controller.processReceiptImage();
          // } else {
          //   Future.delayed(Duration.zero, () {
          //     Get.dialog(
          //       AlertDialog(
          //         title: Text("tidak dapat terhubung ke internet"),
          //         content: Text("Periksa kembali koneksi internet anda"),
          //         actions: [
          //           TextButton(
          //             onPressed: () {
          //               Get.back(); // Tutup dialog
          //               Get.back(); // Kembali ke halaman sebelumnya
          //             },
          //             child: Text("OK"),
          //           ),
          //         ],
          //       ),
          //     );
          //   });
          // }
        },
        builder: (_) {
          print(controller.isProcessing.value);
          if (controller.isProcessing.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.processedText.value == null) {
            Future.delayed(Duration.zero, () {
              Get.dialog(
                AlertDialog(
                  title: Text("Struk tidak terdeteksi"),
                  content: Text("Cek kembali gambar yang diunggah"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        Get.back(); // Kembali ke halaman sebelumnya
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            });
            return SizedBox(); // Mengembalikan widget kosong agar tidak error
          }
          print(controller.processedText.value!.total);
          return Center(
            child: Text(controller.processedText.value!.total.toString()),
          );
        },
      ),
    );
  }
}

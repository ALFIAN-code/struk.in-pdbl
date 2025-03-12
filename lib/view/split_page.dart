import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strukin/controller/struk_controller.dart';

class SplitPage extends StatelessWidget {
  SplitPage({super.key});

  final controller = Get.find<StrukController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<StrukController>(
        init: StrukController(),
        initState: (state) => controller.processReceiptImage(),
        builder: (_) {
          print(controller.isProcessing.value);
          if (controller.isProcessing.value) {
            return Center(child: CircularProgressIndicator());
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

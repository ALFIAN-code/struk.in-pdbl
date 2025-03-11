import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strukin/controller/struk_controller.dart';

class SplitPage extends StatelessWidget {
  SplitPage({super.key});

  final controller = Get.find<StrukController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.processReceiptImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            // child: ,
          );
        }

        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                controller.getImageFromCamera();
              },
              child: Text('From camera'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.getImageFromGallery().then((value) {
                  if (controller.isProcessing.value == false) {
                    controller.processReceiptImage();
                  }
                });
              },
              child: Text('From gallery'),
            ),
            if (controller.isProcessing.value)
              Center(child: CircularProgressIndicator()),
            if (controller.ocrText.value != null)
              Text(controller.ocrText.value!),
            if (controller.processedText != null)
              Text(controller.processedText!.value.total.toString()),
          ],
        );
      },
    );
  }
}

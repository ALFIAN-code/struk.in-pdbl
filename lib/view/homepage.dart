import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:strukin/controller/struk_controller.dart';
import 'package:strukin/view/split_page.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  var controller = Get.put(StrukController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              if (controller.receiptImage.value != null) {
                return Image.file(File(controller.receiptImage.value!.path));
              } else {
                return Text('No image selected');
              }
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.getImageFromCamera().then((value) {
                      if (controller.receiptImage.value != null) {
                        Get.to(() => SplitPage());
                      }
                    });
                  },
                  child: Text('From camera'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.getImageFromGallery().then((value) {
                      if (controller.receiptImage.value != null) {
                        Get.to(() => SplitPage());
                      }
                    });
                  },
                  child: Text('From gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

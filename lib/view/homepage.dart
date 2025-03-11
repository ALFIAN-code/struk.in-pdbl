import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:strukin/controller/struk_controller.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  var controller = Get.put(StrukController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                controller.getImageFromCamera();
              },
              child: Text('From camera'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.getImageFromGallery();
              },
              child: Text('From gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

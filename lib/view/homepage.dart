import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:strukin/controller/struk_controller.dart';
import 'package:strukin/view/component/button.dart';
import 'package:strukin/view/select_item.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  var controller = Get.put(StrukController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),

            MyButton(
              text: "Scan Struk",
              onTap: () {
                Get.bottomSheet(
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      children: [
                        MyButton(
                          text: "Buka kamera",
                          onTap: () {
                            controller
                                .getImage(fromCamera: true)
                                .then(
                                  (value) => Get.to(() {
                                    if (controller.image != null) {
                                      Get.to(() => SelectItem());
                                    }
                                  }),
                                );
                          },
                        ),
                        MyButton(
                          text: "Pilih dari galeri",
                          onTap: () {
                            controller.getImage(fromCamera: false).then((
                              value,
                            ) {
                              if (controller.image != null) {
                                Get.to(() => SelectItem());
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:get/get.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_model_from_api.dart';
import 'package:strukin/model/struk_scan_from_api.dart';

class StrukController extends GetxController {
  Rx<ReceiptModel> struk = ReceiptModel().obs;
  File? image;

  Future<void> scanReceipt(File image) async {
    struk.value = await StrukScanFromApi.postReceiptImage(image);
  }

  Future<void> getImage({required bool fromCamera}) async {
    image =
        fromCamera
            ? await Utils.getImageFromCamera()
            : await Utils.getImageFromGallery();
  }
}

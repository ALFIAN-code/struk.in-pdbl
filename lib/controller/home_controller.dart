import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class StrukController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var fullStrukList = <TransaksiModel>[].obs;

  Rx<XFile?> receiptImage = Rx<XFile?>(null);

  var database = DatabaseHelper();
  // var listStruk = <Transaksi>[];
  Rx<List<TransaksiModel>> strukList = Rx<List<TransaksiModel>>([]);

  Future<void> deleteStruk(int id) async {
    await database.deleteFullTransaksi(id);
    await getAllStruk(); // Refresh the list after deletion
  }

  // Fungsi search untuk filter list transaksi
  void searchStruk(String query) {
    if (query.isEmpty) {
      strukList.value = fullStrukList;
    } else {
      strukList.value =
          fullStrukList.where((transaksi) {
            return transaksi.storeName?.toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                false;
          }).toList();
    }
  }

  Future<void> getAllStruk() async {
    fullStrukList.value = await database.getAllTransaksi();
    strukList.value = fullStrukList;
  }

  Future<XFile?> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      print('file ditemukan ' + pickedImage.path);
      // return pickedImage;

      // Konversi RAW ke JPG jika perlu
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedImage.path,
        "${pickedImage.path}.jpg",
        quality: 90,
      );
      return compressedFile;
    } else {
      return null;
    }
  }

  Future<XFile?> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // receiptImage.value = pickedImage;
      print('file ditemukan ' + pickedImage.path);
      // Konversi RAW ke JPG jika perlu
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedImage.path,
        "${pickedImage.path}.jpg",
        quality: 90,
      );
      return compressedFile;
    } else {
      return null;
    }
  }
}

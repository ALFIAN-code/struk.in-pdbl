import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/detail_transaksi.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/model/transaksi.dart';

class StrukController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  Rx<XFile?> receiptImage = Rx<XFile?>(null);

  var database = DatabaseHelper();
  var listStruk = <Transaksi>[];
  Rx<List<StrukFromApi>> strukList = Rx<List<StrukFromApi>>([]);

  // Future<void> getAllStruk() async {
  //   var result = await database.queryAllTransaksi();
  //   listStruk = result.map((e) => Transaksi.fromMap(e)).toList();
  // }

  // Future<Transaksi> getSingleStruk(int id) async {
  //   var result = await database.getDetailTransaksi(id);
  //   return Transaksi.fromMap(result!);
  // }

  // Future<DetailTransaksi> getDetailStruk(int id) async {
  //   var result = await database.getDetailTransaksi(id);
  //   return DetailTransaksi.fromMap(result!);
  // }

  // Future<Usersplit> getParticipant(int id) async {
  //   var result = await database.getUsersplit(id);
  //   return Usersplit.fromMap(result!);
  // }

  Future<XFile?> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      print('file ditemukan ' + pickedImage.path);
      return pickedImage;
    } else {
      return null;
    }
  }

  Future<XFile?> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // receiptImage.value = pickedImage;
      print('file ditemukan ' + pickedImage.path);
      return pickedImage;
    } else {
      return null;
    }
  }
}

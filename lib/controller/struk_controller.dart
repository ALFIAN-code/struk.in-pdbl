import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/database/remote_from_gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/model/transaksi.dart';

class StrukController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Rx<XFile?> receiptImage = Rx<XFile?>(null);
  Rx<String?> ocrText = ''.obs;
  Rx<StrukFromApi?> processedText = Rx<StrukFromApi?>(null);
  final Rx<bool> isProcessing = false.obs;
  final List<String> _categories = [];
  Rx<List<Transaksi>> strukList = Rx<List<Transaksi>>([]);

  //database
  var database = DatabaseHelper();

  Future<void> getAllStruk() async {
    var transaksi = await database.queryAllDetailTransaksi();
    var listStruk = transaksi.map((e) => Transaksi.fromMap(e)).toList();
    strukList.value = listStruk;
  }

  Future<void> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      receiptImage.value = pickedImage;
      // await processReceiptImage();
    }
  }

  Future<void> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      receiptImage.value = pickedImage;
      // await processReceiptImage();
    }
  }

  Future<void> processReceiptImage() async {
    if (receiptImage.value == null) return;
    isProcessing.value = true;
    // ocrText.value = '';
    // processedText.value = ;

    try {
      final inputImage = InputImage.fromFilePath(receiptImage.value!.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final order = await processReceipt(
        recognizedText.text,
        geminiApi,
        _categories,
      );
      ocrText.value = recognizedText.text;
      processedText.value = order;
      print('Order: $processedText');
    } catch (e) {
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }
}

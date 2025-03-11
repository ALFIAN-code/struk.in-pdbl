import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/controller/gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/struk_model.dart';

class StrukController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Rx<XFile>? _receiptImage;
  Rx<String?> _ocrText = ''.obs;
  Rx<Order>? __procesedTextText;
  final Rx<bool> _isProcessing = false.obs;
  final List<String> _categories = [];

  Future<void> getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      _receiptImage!.value = pickedImage;
      await processReceiptImage();
    }
  }

  Future<void> getImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _receiptImage!.value = pickedImage;
      await processReceiptImage();
    }
  }

  Future<void> processReceiptImage() async {
    if (_receiptImage?.value == null) return;

    _isProcessing.value = true;
    _ocrText.value = null;
    __procesedTextText = null;

    try {
      final inputImage = InputImage.fromFilePath(_receiptImage!.value.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final order = await processReceipt(
        recognizedText.text,
        geminiApi,
        _categories,
      );
      _ocrText.value = recognizedText.text;
      __procesedTextText?.value = order;
    } catch (e) {
      _ocrText.value = e.toString();
      __procesedTextText = null;
    } finally {
      _isProcessing.value = false;
    }
  }
}

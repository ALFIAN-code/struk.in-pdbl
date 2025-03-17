import 'dart:collection';
import 'dart:math';

import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/database/remote_from_gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/menu_items.dart';
import 'package:strukin/model/struk_from_api.dart';

class SplitpageController extends GetxController {
  // Store selected items for each participant
  List<HashSet<MenuItems>> selectedItemsPerParticipant = [];

  final List<int> _availableImages = List.generate(39, (index) => index + 1);
  Rx<List<int>> usedImages = Rx<List<int>>([]);
  Rx<List<Map<String, dynamic>>> participants = Rx<List<Map<String, dynamic>>>(
    [],
  );
  final Random _random = Random();
  int selectedIndex = 0;
  late String defaultProfileImage;
  Rx<StrukFromApi?> processedText = Rx<StrukFromApi?>(null);

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Rx<String?> ocrText = ''.obs;

  var isProcessing = false.obs;

  final List<String> _categories = [
    'Kuliner',
    'Belanja',
    'Transportasi',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Elektronik',
    'Pakaian',
    'Otomotif',
    'lainnya',
  ];

  Future<void> processReceiptImage(XFile image) async {
    isProcessing.value = true;

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        isProcessing.value = false;
        return;
      }

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

  void addFirstParticipant() {
    if (participants.value.isEmpty) {
      int firstImage =
          _random.nextInt(39) + 1; // Choose the first image randomly
      usedImages.add(firstImage);
      selectedItemsPerParticipant.add(
        HashSet<MenuItems>(),
      ); // Initialize selection for the first participant

      participants.value.add({
        "name": "USER 1",
        "image": "assets/images/profile/image$firstImage.png",
        "selected": false,
      });
    }
  }

  void doMultiSelection(MenuItems item) {
    if (selectedItemsPerParticipant.isEmpty)
      return; // No participants available

    var currentSelection = selectedItemsPerParticipant[selectedIndex];
    if (currentSelection.contains(item)) {
      currentSelection.remove(item);
    } else {
      currentSelection.add(item);
    }
  }

  void addParticipant() {
    if (usedImages.length >= 39) return; // Stop if all images are used

    int newImage;
    do {
      newImage = _random.nextInt(39) + 1;
    } while (usedImages.contains(newImage));

    usedImages.add(newImage);
    selectedItemsPerParticipant.add(
      HashSet<MenuItems>(),
    ); // Initialize selection for the new participant

    participants.value.add({
      "name": "USER ${participants.value.length + 1}",
      "image": "assets/images/profile/image$newImage.png",
      "selected": false,
    });
    selectedItemsPerParticipant.add(
      HashSet<MenuItems>(),
    ); // Initialize selection for the new participant
  }

  void selectProfile(int index) {
    for (var participant in participants.value) {
      participant["selected"] = false;
    }
    participants.value[index]["selected"] = true;
    selectedIndex = index; // Update the selected index
  }

  void deleteParticipant(int index) {
    int removedImage = int.parse(
      participants.value[index]["image"]
          .replaceAll("assets/images/profile/image", "")
          .replaceAll(".png", ""),
    );
    usedImages.value.remove(
      removedImage,
    ); // Remove from usedImages to allow reuse
    participants.value.removeAt(index); // Remove participant from the list
    selectedItemsPerParticipant.removeAt(
      index,
    ); // Remove selection for the deleted participant
  }
}

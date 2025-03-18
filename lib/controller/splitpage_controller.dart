import 'dart:collection';
import 'dart:math';

import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/database/remote_from_gemini.dart';
import 'package:strukin/gemini_key.dart';
import 'package:strukin/model/struk_from_api.dart';

class SplitpageController extends GetxController {
  List<Item> selectedItem = [];

  final List<int> _availableImages = List.generate(39, (index) => index + 1);
  Rx<List<int>> usedImages = Rx<List<int>>([]);
  var participants = Rx<List<Map<String, dynamic>>>([]);
  final Random _random = Random();
  var selectedIndex = 0.obs;
  // late String defaultProfileImage;
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

    // try {
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.text.isEmpty) {
      isProcessing.value = false;
      print('kosoongggg ocrnya');
      return;
    }

    final order = await processReceipt(
      recognizedText.text,
      geminiApi,
      _categories,
    );

    ocrText.value = recognizedText.text;
    print('ocr: $ocrText');
    processedText.value = order;
    print('Order: $processedText');

    isProcessing.value = false;
  }

  List<int> getParticipantsWhoSelectedItem(Item item) {
    List<int> participantsWhoSelected = [];
    for (var i = 0; i < participants.value.length; i++) {
      if (participants.value[i]['selectedItems'].contains(item)) {
        participantsWhoSelected.add(i);
      }
    }
    return participantsWhoSelected;
  }

  void trigerUpdate() {
    update();
  }

  void addFirstParticipant() {
    if (participants.value.isEmpty) {
      int firstImage =
          _random.nextInt(39) + 1; // Pilih gambar pertama secara acak
      usedImages.value.add(firstImage);

      participants.value.add({
        "id": Utils.generateCustomUUID(),
        "name": "USER 1",
        "image": "assets/images/profile/image$firstImage.png",
        "selected": false,
        "selectedItems": <Item>[],
      });
    }
  }

  void clearSelectedMenu(int participantIndex) {
    // selectedItem.clear();

    selectedItem = participants.value[participantIndex]['selectedItems'];

    update();
  }

  void doMultiSelection(Item item, int participantIndex) {
    // Clear selected items for other participants
    // for (int i = 0; i < participants.value.length; i++) {
    //   if (i != participantIndex) {
    //     participants.value[i]['selectedItems'].clear();
    //   }
    // }

    // Add or remove item from the selectedItems of the current participant
    // Clear previous selections only if the participant is different
    // if (participants.value[participantIndex]['selectedItems'].contains(item)) {
    // participants.value[participantIndex]['selectedItems'].remove(item);
    // } else {

    // }
    if (selectedItem.contains(item)) {
      participants.value[participantIndex]['selectedItems'].remove(item);
      selectedItem.remove(item);
    } else {
      participants.value[participantIndex]['selectedItems'].add(item);
      selectedItem.add(item);
    }
    print(participants.value[participantIndex]['selectedItems']);
    print(selectedItem.toList());
    update();
  }

  void addParticipant() {
    if (usedImages.value.length >= 39)
      return; // Jika semua gambar sudah dipakai, hentikan

    int newImage;
    do {
      newImage = _random.nextInt(39) + 1;
    } while (usedImages.value.contains(newImage));

    usedImages.value.add(newImage);

    participants.value.add({
      "id": Utils.generateCustomUUID(),
      "name": "USER ${participants.value.length + 1}",
      "image": "assets/images/profile/image$newImage.png",
      "selected": false,
      "selectedItems": <Item>[], // Initialize selectedItems here
    });
    update();
  }

  void selectProfile(int index) {
    for (var participant in participants.value) {
      participant["selected"] = false;
    }
    participants.value[index]["selected"] = true;
    update();
  }

  void deleteParticipant(int index) {
    int removedImage = int.parse(
      participants.value[index]["image"]
          .replaceAll("assets/images/profile/image", "")
          .replaceAll(".png", ""),
    );
    usedImages.value.remove(removedImage);

    print('fungsi terpanggil');
    participants.value.removeAt(index);
    update();
  }

  sendToDatabase() {}
}

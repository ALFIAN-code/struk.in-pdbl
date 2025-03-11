import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class Utils {
  static Future<File?> _cropImage(File imageFile) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.lightBlue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    if (croppedImage != null) {
      return File(croppedImage.path);
    }
    return null;
  }

  static Future<File?> getImageFromCamera() async {
    File? image0;
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      image0 = File(image.path);
      return image0;
    }
    return null;
  }

  static Future<File?> getImageFromGallery() async {
    File? image0;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      image0 = File(image.path);
      return image0;
    }
    return null;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class Fullscreen extends StatelessWidget {
  const Fullscreen({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(''),
      ),
      body: Center(
        child: PinchZoom(
          child: Image.file(file, width: double.infinity, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

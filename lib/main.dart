import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:strukin/view/Detailpage.dart';
import 'package:strukin/view/result_page.dart';
import 'package:strukin/view/split_page.dart';
import 'view/onboarding_screen.dart';
import 'package:strukin/view/Homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const /*HomePage()*/ DetailPage(),
    );
  }
}

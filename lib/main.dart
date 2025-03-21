import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/view/Homepage.dart';

void main(List<String> args) async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    // deleteDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

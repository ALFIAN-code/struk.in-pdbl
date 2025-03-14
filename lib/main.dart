import 'package:flutter/material.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const /*HomePage()*/ SplitPage(),
    );
  }
}
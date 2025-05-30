import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:strukin/controller/internet_connection_controller.dart';
import 'package:strukin/database/database_helper.dart';


import 'package:strukin/view/Homepage.dart';
import 'package:strukin/view/onboarding_screen.dart';

import 'package:strukin/view/style.dart';

/// Entry point utama aplikasi Struk.in
///
/// Melakukan:
/// - Inisialisasi Flutter
/// - Mengunci orientasi ke portrait
/// - Mengecek status onboarding
/// - Menjalankan aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool('hasCompletedOnboarding') ?? false;

  await DatabaseHelper().database;
  var database =  DatabaseHelper();
  await database.manualMigrateIfNeeded();
  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class MyApp extends StatefulWidget {
  final bool hasCompletedOnboarding;
  MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final internetConnectionController = Get.put(ConnectionController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white, // Warna utama
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: mainColor,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ), // Maksimum 500px
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                      widget.hasCompletedOnboarding
                          ? Column(
                            children: [
                              Expanded(child: HomePage()),
                              Obx(
                                () =>
                                    internetConnectionController
                                            .hasConnection
                                            .value
                                        ? const SizedBox()
                                        : Container(
                                          // height: 50,
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            10,
                                            0,
                                            0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade400,
                                          ),

                                          child: SafeArea(
                                            top: false,
                                            bottom: true,
                                            child: Center(
                                              child: Text(
                                                'Tidak ada koneksi internet',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          )
                          : OnboardingScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

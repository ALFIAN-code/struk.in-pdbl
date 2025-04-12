import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:strukin/controller/internet_connection_controller.dart';

import 'package:strukin/view/Homepage.dart';
import 'package:strukin/view/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  MyApp({super.key, required this.hasCompletedOnboarding});

  var internetConnectionController = Get.put(ConnectionController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white, // Warna utama
      ),
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.yellow[50],
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Maksimum 500px
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    hasCompletedOnboarding
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
                                        height: 50,
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          6,
                                          0,
                                          15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade400,
                                        ),

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
                          ],
                        )
                        : OnboardingScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}

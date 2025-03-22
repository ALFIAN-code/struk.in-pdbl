import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:get/get.dart';
import 'package:strukin/view/Homepage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  int bottonwidth = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Selamat Datang di Struk.In!",
      "description":
          "Makan bareng teman jadi lebih mudah! Tak perlu ribet hitung manual, biar kami yang urus pembagian tagihan untukmu.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Baca Tagihan dengan Mudah",
      "description":
          "Cukup foto strukmu, dan kami akan otomatis membaca isi tagihan. Tak perlu input satu per satu lagi!",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Bagi Tagihan Tanpa Ribet",
      "description":
          "Tagihan langsung terbagi sesuai pesanan masing-masing. Transparan, cepat, dan adil untuk semua!",
    },
  ];

  _animationLogic() {
    if (bottonwidth == 0) {
      setState(() {
        bottonwidth = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                if (index == 2) {
                  bottonwidth = 0;
                }
                setState(() {
                  _currentPage = index;
                });
                if (index == 2) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _animationLogic();
                  });
                }
              },
              itemCount: onboardingData.length,
              itemBuilder:
                  (context, index) => buildPage(
                    image: onboardingData[index]["image"]!,
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: AnimatedSizeAndFade(
              child:
                  _currentPage != 2
                      ? Column(
                        children: [
                          SmoothPageIndicator(
                            controller: _controller,
                            count: onboardingData.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: Colors.orange,
                              dotColor: Colors.grey,
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _controller.jumpToPage(2);
                                },
                                child: Text(
                                  "Skip",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward, size: 28),
                              ),
                            ],
                          ),
                        ],
                      )
                      : GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasCompletedOnboarding', true);

                          Get.off(
                            HomePage(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(15),
                          width: width * bottonwidth,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Mulai",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

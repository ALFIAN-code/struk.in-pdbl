import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:strukin/controller/internet_connection_controller.dart';

import 'package:strukin/view/Homepage.dart';
import 'package:strukin/view/onboarding_screen.dart';

import 'package:shorebird_code_push/shorebird_code_push.dart';

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

  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

/// Widget utama aplikasi yang mengatur:
/// - Tema global
/// - Halaman awal (onboarding/home)
/// - Pengecekan koneksi internet
class MyApp extends StatefulWidget {
  final bool hasCompletedOnboarding;
  MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final internetConnectionController = Get.put(ConnectionController());
  final _updater = ShorebirdUpdater();
  late final bool _isUpdaterAvailable;
  var _currentTrack = UpdateTrack.stable;
  var _isCheckingForUpdates = false;
  Patch? _currentPatch;

  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;

    try {
      setState(() => _isCheckingForUpdates = true);
      final status = await _updater.checkForUpdate(track: _currentTrack);

      debugPrint('🟡 Shorebird update status: $status');

      if (!mounted) return;

      switch (status) {
        case UpdateStatus.upToDate:
          _showNoUpdateAvailableBanner();
          break;
        case UpdateStatus.outdated:
          _showUpdateAvailableBanner();
          break;
        case UpdateStatus.restartRequired:
          _showRestartBanner();
          break;
        case UpdateStatus.unavailable:
          debugPrint('⚠️ Update unavailable');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error checking for update: $e');
      _showErrorBanner(e);
    } finally {
      setState(() => _isCheckingForUpdates = false);
    }
  }

  void _showDownloadingBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        const MaterialBanner(
          content: Text('Downloading...'),
          actions: [
            SizedBox(height: 14, width: 14, child: CircularProgressIndicator()),
          ],
        ),
      );
  }

  void _showUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'Update available for the ${_currentTrack.name} track.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                await _downloadUpdate();
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
  }

  void _showNoUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'No update available on the ${_currentTrack.name} track.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  void _showRestartBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text(
            'Patch berhasil diunduh! Silakan restart aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                // Bisa tambahkan exit(0) jika kamu benar-benar ingin force restart
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
  }

  void _showErrorBanner(Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'An error occurred while downloading the update: $error.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  Future<void> _downloadUpdate() async {
    _showDownloadingBanner();
    try {
      await _updater.update(track: _currentTrack);
      debugPrint('✅ Update downloaded');
      if (!mounted) return;
      _showRestartBanner();
    } on UpdateException catch (e) {
      debugPrint('❌ Download failed: ${e.message}');
      _showErrorBanner(e.message);
    }
  }

  @override
  void initState() {
    super.initState();

    _isUpdaterAvailable = _updater.isAvailable;

    _updater
        .readCurrentPatch()
        .then((patch) {
          setState(() => _currentPatch = patch);
        })
        .catchError((e) => debugPrint('Patch read error: $e'));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate(); // <<-- PENTING!
    });
  }

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

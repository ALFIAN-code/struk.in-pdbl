import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:strukin/controller/internet_connection_controller.dart';
// import 'package:rive/rive.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/category_enum.dart';
import 'package:strukin/model/struk_model.dart';
import 'package:strukin/view/Detailpage.dart';
import 'package:strukin/view/component/bottom_sheet.dart';
import 'package:strukin/view/split_page.dart';
import 'package:strukin/view/style.dart';

import '../controller/home_controller.dart';

// import 'package:awesome_dialog/awesome_dialog.dart';

/// Halaman utama aplikasi yang menampilkan:
/// - Tombol untuk memindai struk baru
/// - Daftar struk yang tersimpan
/// - Fungsi pencarian struk
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.put(HomepageController());
  final connection = Get.find<ConnectionController>();

  // Future<int> _fetchDbVersion() async {
  //   final db = await DatabaseHelper().database;
  //   return db.getVersion();
  // }

  /// Menampilkan bottom sheet untuk memilih sumber gambar (kamera atau galeri)
  ///
  /// [context] - BuildContext untuk menampilkan modal bottom sheet
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  var result = await controller.getImageFromCamera();
                  if (!connection.hasConnection.value) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Tidak ada koneksi internet',
                      text:
                          'Silakan periksa koneksi internet Anda dan coba lagi.',
                      confirmBtnText: 'OK',
                      onConfirmBtnTap: () {
                        Get.back(); // Kembali ke halaman sebelumnya
                      },
                    );
                  } else {
                    if (result != null) {
                      Get.to(() => SplitPage(image: result));
                    } else {
                      Get.snackbar(
                        'Error',
                        'Tidak ada gambar yang terpilih',
                        backgroundColor: Colors.white,
                      );
                    }
                  }

                  // });
                },
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: Text(
                  'Buka kamera',
                  style: GoogleFonts.roboto(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  var result = await controller.getImageFromGallery();
                  if (!connection.hasConnection.value) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Tidak ada koneksi internet',
                      text:
                          'Silakan periksa koneksi internet Anda dan coba lagi.',
                      confirmBtnText: 'OK',
                      onConfirmBtnTap: () {
                        Get.back(); // Kembali ke halaman sebelumnya
                      },
                    );
                  } else {
                    if (result != null) {
                      Get.to(() => SplitPage(image: result));
                    } else {
                      Get.snackbar('Error', 'Tidak ada gambar yang terpilih');
                      Get.back();
                    }
                  }
                  // });
                },
                icon: const Icon(Icons.image, color: Colors.black54),
                label: Text(
                  'Ambil dari galeri',
                  style: GoogleFonts.roboto(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 237, 215),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: mainColor)),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello There',
                              style: GoogleFonts.roboto(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scan Strukmu sekarang',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (!Get.isSnackbarOpen) {
                              Get.snackbar(
                                "Easter egg",
                                Utils.randomQuotes(),
                                backgroundColor: Colors.white,

                                borderRadius: 30,
                                borderWidth: 1,
                                borderColor: const Color.fromARGB(
                                  255,
                                  214,
                                  214,
                                  214,
                                ),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              'assets/images/Deliveryboy.png',
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Container(
                        height: 85,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan Struk Baru',
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Tekan disini untuk scan struk baru',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.add_rounded,
                              color: Colors.black,
                              size: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                controller.searchStruk(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search disini ...',
                                hintStyle: GoogleFonts.roboto(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Struk tersimpan',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.white,

                            // shadowColor: Colors.black,
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => FilterButtomSheet(),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text('Filter', style: GoogleFonts.roboto()),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.filter_list,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => Text(
                        'Filter berdasarkan : ${controller.selectedCategory.value} - ${controller.selectedTime.value}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GetX(
                      init: controller,
                      initState: (state) {
                        controller.getAllStruk();
                      },
                      builder: (controller) {
                        // print(controller.strukList.value.toList());
                        // var sortedList =
                        //     controller.filteredStrukList.value;
                        if (controller.filteredStrukList.value.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                SizedBox(height: 40),
                                Image.asset(
                                  'assets/images/empy-state.png',
                                  height: 300,
                                ),
                                // const SizedBox(height: 20),
                                Text(
                                  'Struk tidak di temukan',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: List.generate(
                              controller.filteredStrukList.value.length,
                              (index) {
                                final transaksi =
                                    controller.filteredStrukList.value[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => DetailPage(transaksi: transaksi),
                                      );
                                    },
                                    child: StrukItem(
                                      onDelete: () async {
                                        await QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: 'Konfirmasi',

                                          text:
                                              'Apakah Anda yakin ingin menghapus struk ini?',
                                          confirmBtnText: 'Hapus',
                                          cancelBtnText: 'Batal',
                                          showCancelBtn: true,
                                          onConfirmBtnTap: () async {
                                            await controller.deleteStruk(
                                              transaksi.transaksiID!,
                                            );
                                            Get.back();
                                          },

                                          confirmBtnColor: Colors.red,
                                        );
                                      },
                                      transaksiItem: transaksi,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan item struk dalam daftar
///
/// Berisi:
/// - Gambar struk
/// - Nama toko
/// - Total
class StrukItem extends StatelessWidget {
  const StrukItem({
    super.key,
    required this.transaksiItem,
    required this.onDelete,
  });
  final void Function()? onDelete;

  /// Model transaksi yang akan ditampilkan
  final TransaksiModel transaksiItem;

  @override
  /// Membangun tampilan item struk
  ///
  /// [context] - BuildContext untuk membangun widget
  ///
  /// Returns:
  /// - Container yang berisi informasi struk (gambar, nama toko, total, dll)
  Widget build(BuildContext context) {
    CategoryStruk category = CategoryStruk.fromLabel(transaksiItem.category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.file(
                  File(transaksiItem.imagePath!),
                  width: 85,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaksiItem.storeName ?? 'unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total: ${Utils.formatCurrency(transaksiItem.total!.toInt())}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${transaksiItem.jumlahparticipant} partisipan',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            Utils.formatDateFromString(transaksiItem.strukDate),
                            style: GoogleFonts.roboto(color: Colors.black54),
                          ),

                          SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              category.label,
                              style: GoogleFonts.roboto(
                                color: category.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    height: 31,
                    width: 31,
                    decoration: BoxDecoration(
                      color: Color(0xffFF4E4E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

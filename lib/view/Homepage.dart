import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:strukin/controller/internet_connection_controller.dart';
// import 'package:rive/rive.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_model.dart';
import 'package:strukin/view/Detailpage.dart';
import 'package:strukin/view/split_page.dart';
import 'package:strukin/view/style.dart';

import '../controller/home_controller.dart';

// import 'package:awesome_dialog/awesome_dialog.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.put(StrukController());
  var internetConnectionController = Get.put(ConnectionController());

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
                  // .then((value) {
                  CircularProgressIndicator();

                  if (result != null) {
                    Get.to(SplitPage(image: result));
                  } else {
                    Get.snackbar('Error', 'Tidak ada gambar yang terpilih');
                  }
                  // });
                },
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: Text(
                  'Buka kamera',
                  style: GoogleFonts.roboto(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
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
                  CircularProgressIndicator();

                  // then((_) {
                  if (result != null) {
                    Get.to(SplitPage(image: result));
                  } else {
                    Get.snackbar('Error', 'Tidak ada gambar yang terpilih');
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
      bottomSheet: GetBuilder<ConnectionController>(
        init: ConnectionController(),
        builder:
            (controller) =>
                controller.hasConnection.value
                    ? const SizedBox()
                    : Container(
                      height: 50,
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          'Tidak ada koneksi internet',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE8AD), Color(0xFFFFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
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
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            'assets/images/Deliveryboy.png',
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Container(
                        height: 85,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(12),
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
                                    'tekan disini untuk scan struk baru',
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
                    const SizedBox(height: 30),
                    Row(
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
                                hintText: 'Search disini bes......',
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
                            icon: Image.asset(
                              'assets/images/search.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Struk tersimpan',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GetX(
                      init: controller,
                      initState: (state) => controller.getAllStruk(),
                      builder: (controller) {
                        print(controller.strukList.value.toList());
                        if (controller.strukList.value.isEmpty) {
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
                                  'struk tidak di temukan',
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
                              controller.fullStrukList.length,
                              (index) {
                                final transaksi =
                                    controller.fullStrukList[index];

                                return Dismissible(
                                  key: Key(
                                    transaksi.transaksiID.toString(),
                                  ), // Unique key
                                  direction:
                                      DismissDirection
                                          .endToStart, // Swipe ke kiri
                                  background: Container(
                                    margin: EdgeInsets.fromLTRB(10, 15, 10, 30),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(10),
                                      ),
                                    ), // Warna background saat swipe
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'Konfirmasi',

                                      text:
                                          'Apakah Anda yakin ingin menghapus struk ini?',
                                      confirmBtnText: 'Hapus',
                                      cancelBtnText: 'batal',
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
                                  onDismissed: (direction) async {
                                    await controller.deleteStruk(
                                      transaksi.transaksiID!,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          DetailPage(transaksi: transaksi),
                                        );
                                      },
                                      child: StrukItem(
                                        transaksiItem: transaksi,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StrukItem extends StatelessWidget {
  const StrukItem({super.key, required this.transaksiItem});
  final TransaksiModel transaksiItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(transaksiItem.imagePath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksiItem.storeName ?? 'unknown',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${Utils.formatCurrency(transaksiItem.total!.toInt())}  |  ${transaksiItem.jumlahparticipant} partisipan',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        transaksiItem.strukDate ?? 'unknown',
                        style: GoogleFonts.roboto(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

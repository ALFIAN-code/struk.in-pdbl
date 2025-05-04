import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';
import 'package:strukin/controller/internet_connection_controller.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/view/Homepage.dart';
import 'package:strukin/view/component/menu_item.dart';
import 'package:strukin/view/component/particpant_item.dart';
import 'package:strukin/view/edit_page.dart';
import 'package:strukin/view/result_page.dart';
import 'package:strukin/view/style.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key, required this.image});
  final XFile image;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  // Menyimpan item ke multi-selection
  var splitController = Get.put(SplitpageController());
  var connection = Get.find<ConnectionController>();

  late bool internetConnection;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // splitController.processReceiptImage(
    //   widget.image,
    //   connection.hasConnection.value,
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      splitController.processReceiptImage(
        widget.image,
        connection.hasConnection.value,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splitController.addParticipant();
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    splitController.resetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Color(0xffFFF3E0)),
        child: Obx(() {
          if (splitController.isProcessing.value) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/loading.json', height: 200),
                  Text(
                    'Memproses gambar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }
          if (splitController.processedText.value!.isStruk! == false) {
            Future.microtask(() {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Gagal memproses gambar',
                text:
                    'Gambar yang Anda unggah tidak tampak sebagai foto struk yang valid. Mohon unggah ulang gambar struk yang jelas.',
                confirmBtnText: 'OK',
                onConfirmBtnTap: () {
                  splitController.resetState();
                  Get.offAll(() => HomePage()); // Kembali ke halaman sebelumnya
                },
              );
            });
          }

          if (connection.hasConnection.value == false &&
              splitController.processedText.value!.businessName!.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Tidak ada koneksi internet',
                text: 'Silakan periksa koneksi internet Anda dan coba lagi.',
                confirmBtnText: 'OK',
                onConfirmBtnTap: () {
                  splitController.resetState();
                  Get.offAll(() => HomePage()); // Kembali ke halaman sebelumnya
                },
              );
            });
          }

          if (splitController.isProcessing.value == false) {
            return Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 30),
                                    Text(
                                      'Pilih Item',
                                      style: GoogleFonts.roboto(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Ketuk teman lalu pilih item',
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    title: 'Keluar dari Edit Pembagian?',
                                    text:
                                        'Jika kamu keluar sekarang, semua perubahan pembagian tagihan yang baru saja kamu atur akan dibatalkan dan hilang.',
                                    confirmBtnText: 'Keluar',
                                    confirmBtnColor: accentColor,
                                    confirmBtnTextStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    barrierColor: Colors.black.withAlpha(150),
                                    cancelBtnText: 'Batal',
                                    showCancelBtn: true,
                                    onConfirmBtnTap: () {
                                      // splitController.resetState();
                                      Get.offAll(
                                        () => HomePage(),
                                      ); // Kembali ke halaman sebelumnya
                                    },
                                  );
                                },
                                icon: Icon(Icons.close_rounded, size: 30),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 140,
                          child: GetBuilder(
                            init: SplitpageController(),
                            builder: (controller) {
                              var deviceWIdth =
                                  MediaQuery.of(context).size.width;
                              return Row(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: deviceWIdth * 0.8,
                                    ),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          splitController
                                              .participants
                                              .value
                                              .length,
                                      itemBuilder: (context, index) {
                                        return ParticipantItem(
                                          isLast:
                                              splitController
                                                  .participants
                                                  .value
                                                  .length ==
                                              1,
                                          imgPath:
                                              splitController
                                                  .participants
                                                  .value[index]['image'],
                                          name:
                                              splitController
                                                  .participants
                                                  .value[index]['name'],
                                          isSelected:
                                              splitController
                                                  .selectedIndex
                                                  .value ==
                                              index,
                                          onSelected: () {
                                            setState(() {
                                              splitController
                                                  .selectedIndex
                                                  .value = index;
                                              splitController.clearSelectedMenu(
                                                index,
                                              );
                                            });
                                          },
                                          onNameChanged: (newName) {
                                            setState(() {
                                              splitController
                                                      .participants
                                                      .value[index]['name'] =
                                                  newName;
                                            });
                                          },
                                          onClose: () {
                                            setState(() {
                                              splitController.deleteParticipant(
                                                index,
                                              );
                                              splitController.clearSelectedMenu(
                                                splitController
                                                        .participants
                                                        .value
                                                        .length -
                                                    1,
                                              );
                                              splitController
                                                  .selectedIndex
                                                  .value = splitController
                                                      .participants
                                                      .value
                                                      .length -
                                                  1;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          splitController.addParticipant();
                                          if (splitController
                                                  .usedImages
                                                  .value
                                                  .length ==
                                              58) {
                                            if (!Get.isSnackbarOpen) {
                                              Get.snackbar(
                                                'Batas participant tercapai',
                                                'Kamu sudah menambahkan jumlah maksimal peserta. Hapus peserta lain terlebih dahulu jika ingin menambah yang baru.',
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      194,
                                                    ),
                                                borderRadius: 30,
                                                borderWidth: 1,
                                                borderColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      214,
                                                      214,
                                                      214,
                                                    ),
                                              );
                                            }
                                          }
                                        });
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            });
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.withAlpha(
                                          120,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                splitController
                                        .processedText
                                        .value
                                        ?.businessName ??
                                    '',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Tagihan dibuat: ${splitController.processedText.value?.date ?? '-'}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sertakan Pajak'),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  activeColor: Colors.green,
                                  value: splitController.includePajak.value,
                                  onChanged: (value) {
                                    splitController.includePajak.value = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 5),
                          itemCount:
                              splitController
                                  .processedText
                                  .value!
                                  .items!
                                  .length,
                          itemBuilder: (context, index) {
                            final item =
                                splitController
                                    .processedText
                                    .value
                                    ?.items?[index];
                            return GetListMenu(
                              taxPercentage: splitController.getTaxRatio(),
                              item: item!,
                              isSelected: splitController.selectedItem.contains(
                                item,
                              ),
                              isSelectable: true,
                              onTap: () {
                                setState(() {
                                  splitController.doMultiSelection(
                                    item,
                                    splitController.selectedIndex.value,
                                  );
                                });
                              },
                            );
                          },
                        ),
                        // const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 30,
                          ),
                          child: Column(
                            children: [
                              rowText(
                                'Subtotal (tanpa pajak)',
                                Utils.formatCurrency(
                                  splitController
                                          .processedText
                                          .value
                                          ?.subtotal ??
                                      0,
                                ),
                              ),
                              rowText(
                                'Pajak',
                                Utils.formatCurrency(
                                  splitController.processedText.value?.tax ?? 0,
                                ),
                              ),
                              // rowText('Layanan', '${splitController.processedText.value?.}'),
                              rowText(
                                'Total Tagihan',
                                Utils.formatCurrency(
                                  splitController.processedText.value?.total ??
                                      0,
                                ),
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              print("Tombol edit ditekan");
                              Get.to(() => EditPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffFFFBF2),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              print("Tombol Konfirmasi ditekan");

                              bool isEmpty = splitController.participants.value
                                  .any(
                                    (element) =>
                                        element['selectedItems'].isEmpty,
                                  );

                              if (isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Pilih item terlebih dahulu',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                var transaksi = await splitController
                                    .addDataToDatabase2(widget.image.path);
                                Get.off(
                                  () => ResultPage(
                                    transaksiID: transaksi!.transaksiID!,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(
                                252,
                                207,
                                92,
                                1.0,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Konfirmasi',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('error'));
          }
        }),
      ),
    );
  }
}

// Widget untuk menampilkan teks Subtotal, Pajak, Layanan, dan Total Tagihan
Widget rowText(String label, String value, {bool bold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

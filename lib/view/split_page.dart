import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/view/component/menu_item.dart';
import 'package:strukin/view/component/particpant_item.dart';
import 'package:strukin/view/result_page.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key, required this.image});
  final XFile image;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  // Menyimpan item ke multi-selection

  var splitController = Get.put(SplitpageController());

  @override
  void initState() {
    splitController.processReceiptImage(widget.image);
    splitController.addFirstParticipant();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 232, 173, 1.0),
              Color.fromRGBO(255, 255, 255, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 1.0],
          ),
        ),
        child: Obx(() {
          if (splitController.isProcessing.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (splitController.processedText.value == null) {
            // Menggunakan Future.microtask agar dialog tampil satu kali setelah build selesai
            Future.microtask(() {
              // Get.defaultDialog(
              //   title: 'Error',
              //   middleText: 'Tidak dapat memproses gambar',
              //   textConfirm: 'OK',
              //   onConfirm: () {
              //     Get.back(); // Menutup dialog
              //     Get.back(); // Kembali ke halaman sebelumnya
              //   },
              // );
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Error',
                text: 'Tidak dapat memproses gambar',
                confirmBtnText: 'OK',
                onConfirmBtnTap: () {
                  Get.back();
                  Get.back(); // Kembali ke halaman sebelumnya
                },
              );
            });
            // Return widget kosong agar tidak terjadi error build
            return const SizedBox.shrink();
          }

          if (splitController.isProcessing.value == false) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: GetBuilder<SplitpageController>(
                            init: SplitpageController(),
                            builder: (controller) {
                              return ListView(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ListView.builder(
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
                                          splitController.deleteParticipant(
                                            index,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          splitController.addParticipant();
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
                        ListView.separated(
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
                            return getListMenu(
                              item!,
                              splitController.selectedItem.contains(item),
                              () {
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              rowText(
                                'Subtotal',
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        print("Tombol Konfirmasi ditekan");

                        bool isEmpty = splitController.participants.value.any(
                          (element) => element['selectedItems'].isEmpty,
                        );

                        if (isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Pilih item terlebih dahulu',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } else {
                          var result = await splitController.addDataToDatabase(
                            widget.image.path,
                          );
                          Get.off(() => ResultPage(transaksiModel: result!));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(252, 207, 92, 1.0),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

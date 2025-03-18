import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/view/component/particpant_item.dart';

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
                                '${splitController.processedText.value?.subtotal ?? 0}',
                              ),
                              rowText(
                                'Pajak',
                                '${splitController.processedText.value?.tax ?? 0}',
                              ),
                              // rowText('Layanan', '${splitController.processedText.value?.}'),
                              rowText(
                                'Total Tagihan',
                                '${splitController.processedText.value?.total ?? 0}',
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
                      onPressed: () {
                        print("Tombol Konfirmasi ditekan");
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

// Widget untuk menampilkan Menu Items
InkWell getListMenu(Item item, bool isSelected, VoidCallback onTap) {
  var splitController = Get.find<SplitpageController>();

  var participantWhoSelected = splitController.getParticipantsWhoSelectedItem(
    item,
  );

  return InkWell(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color:
                isSelected
                    ? Color.fromRGBO(252, 207, 92, 1.0)
                    : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(0, 0, 0, 1.0),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.unitPrice}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(40, 40, 40, 1.0),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(90, 90, 90, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.price.toInt()}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(40, 40, 40, 1.0),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    child: Icon(
                      isSelected ? Icons.close : Icons.circle_outlined,
                      size: 20,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
              (participantWhoSelected.isNotEmpty)
                  ? SizedBox(
                    height: 30,
                    child: Row(
                      children:
                          participantWhoSelected.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.orange,
                                child: Image.asset(
                                  splitController
                                      .participants
                                      .value[e]['image'],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ],
    ),
  );
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

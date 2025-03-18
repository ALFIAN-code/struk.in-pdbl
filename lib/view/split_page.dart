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
                                            // splitController.doMultiSelection(
                                            //   splitController
                                            //       .processedText
                                            //       .value!
                                            //       .items![index],
                                            //   index,
                                            // );
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
                        Text(
                          splitController.processedText.value?.businessName ??
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

                        // ListView harus dalam Expanded agar tombol tidak terdorong ke atas
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

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        // Aksi ketika tombol Konfirmasi ditekan
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

// class ParticipantItem extends StatefulWidget {
//   const ParticipantItem({
//     super.key,
//     required this.imgPath,
//     required this.name,
//     this.onTap,
//     this.onNameChanged,
//     required this.isLast,
//     required this.isSelected,
//     required this.onSelected,
//   });
//   final bool isSelected;
//   final bool isLast;
//   final String imgPath;
//   final String name;
//   final void Function()? onTap;
//   final void Function(String)? onNameChanged;
//   final void Function()? onSelected;

//   @override
//   _ParticipantItemState createState() => _ParticipantItemState();
// }

// class _ParticipantItemState extends State<ParticipantItem> {
//   late TextEditingController _controller;
//   late FocusNode _focusNode;
//   bool isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.name);
//     _focusNode = FocusNode();

//     // Listener untuk mendeteksi ketika kehilangan fokus
//     _focusNode.addListener(() {
//       if (!_focusNode.hasFocus) {
//         _saveAndCloseEditing();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _saveAndCloseEditing() {
//     setState(() {
//       isEditing = false;
//     });
//     widget.onNameChanged?.call(_controller.text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         widget.onSelected?.call();
//       },
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color:
//                           widget.isSelected
//                               ? Colors.lightGreen
//                               : Colors.transparent,
//                       width: 4,
//                     ),
//                     borderRadius: BorderRadius.circular(1000),
//                   ),
//                   child: CircleAvatar(
//                     radius: 30,
//                     child: ClipOval(
//                       child: Image.asset(
//                         widget.imgPath,
//                         fit: BoxFit.cover,
//                         width: 60,
//                         height: 60,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: GestureDetector(
//                   onTap: widget.isLast ? null : widget.onTap,
//                   child: Container(
//                     height: 20,
//                     width: 20,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withAlpha(190),
//                     ),
//                     child: const Icon(
//                       Icons.close_rounded,
//                       color: Colors.black,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 isEditing = true;
//               });
//               _focusNode.requestFocus(); // Fokus ke TextField saat diklik
//             },
//             child:
//                 isEditing
//                     ? SizedBox(
//                       width: 80,
//                       height: 15,
//                       child: TextField(
//                         controller: _controller,
//                         focusNode: _focusNode,
//                         autofocus: true,
//                         textAlign: TextAlign.center,
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(vertical: 0),
//                           border: InputBorder.none,
//                         ),
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         onSubmitted: (value) => _saveAndCloseEditing(),
//                       ),
//                     )
//                     : Text(
//                       _controller.text.isEmpty ? "Nama" : _controller.text,
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black54,
//                       ),
//                     ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget untuk menampilkan Menu Items
InkWell getListMenu(Item item, bool isSelected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color:
                isSelected
                    ? Color.fromRGBO(252, 207, 92, 1.0)
                    : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                        '${item.price}',
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
              ],
            ),
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

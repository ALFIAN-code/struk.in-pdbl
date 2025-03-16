<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strukin/controller/struk_controller.dart';
import 'package:strukin/controller/utils.dart';

class SplitPage extends StatelessWidget {
  SplitPage({super.key});

  final controller = Get.find<StrukController>();
=======
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/model/menu_items.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  // Menyimpan item ke multi-selection
  HashSet<MenuItems> selectedItem = HashSet();

  final List<int> _availableImages = List.generate(39, (index) => index + 1);
  final List<int> usedImages = [];
  List<Map<String, dynamic>> participants = [];
  final Random _random = Random();
  int selectedIndex = 0;

  late String defaultProfileImage;

  @override
  void initState() {
    // TODO: implement initState
    addFirstParticipant();
    super.initState();
  }

  void addFirstParticipant() {
    if (participants.isEmpty) {
      int firstImage =
          _random.nextInt(39) + 1; // Pilih gambar pertama secara acak
      usedImages.add(firstImage);

      setState(() {
        participants.add({
          "name": "USER 1",
          "image": "assets/images/profile/image$firstImage.png",
          "selected": false,
        });
      });
    }
  }

  void doMultiSelection(MenuItems item) {
    if (selectedItem.contains(item)) {
      selectedItem.remove(item);
    } else {
      selectedItem.add(item);
    }
    setState(() {});
  }

  void addParticipant() {
    if (usedImages.length >= 39)
      return; // Jika semua gambar sudah dipakai, hentikan

    int newImage;
    do {
      newImage = _random.nextInt(39) + 1;
    } while (usedImages.contains(newImage));

    usedImages.add(newImage);

    setState(() {
      participants.add({
        "name": "USER ${participants.length + 1}",
        "image": "assets/images/profile/image$newImage.png",
        "selected": false,
      });
    });
  }

  void selectProfile(int index) {
    setState(() {
      for (var participant in participants) {
        participant["selected"] = false;
      }
      participants[index]["selected"] = true;
    });
  }

  void deleteParticipant(int index) {
    setState(() {
      int removedImage = int.parse(
        participants[index]["image"]
            .replaceAll("assets/images/profile/image", "")
            .replaceAll(".png", ""),
      );
      usedImages.remove(
        removedImage,
      ); // Hapus dari daftar usedImages agar bisa dipakai lagi
      participants.removeAt(index); // Hapus partisipan dari list
    });
  }
>>>>>>> 6779e272787405bb437f353655cb43207a676bec

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: GetX<StrukController>(
        init: StrukController(),
        initState: (state) async {
          controller.processReceiptImage();
          // var connection = await Utils.checkInternetConnection();
          // print('connection = $connection');
          // if (connection) {
          //   controller.processReceiptImage();
          // } else {
          //   Future.delayed(Duration.zero, () {
          //     Get.dialog(
          //       AlertDialog(
          //         title: Text("tidak dapat terhubung ke internet"),
          //         content: Text("Periksa kembali koneksi internet anda"),
          //         actions: [
          //           TextButton(
          //             onPressed: () {
          //               Get.back(); // Tutup dialog
          //               Get.back(); // Kembali ke halaman sebelumnya
          //             },
          //             child: Text("OK"),
          //           ),
          //         ],
          //       ),
          //     );
          //   });
          // }
        },
        builder: (_) {
          print(controller.isProcessing.value);
          if (controller.isProcessing.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.processedText.value == null) {
            Future.delayed(Duration.zero, () {
              Get.dialog(
                AlertDialog(
                  title: Text("Struk tidak terdeteksi"),
                  content: Text("Cek kembali gambar yang diunggah"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        Get.back(); // Kembali ke halaman sebelumnya
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            });
            return SizedBox(); // Mengembalikan widget kosong agar tidak error
          }
          print(controller.processedText.value!.total);
          return Center(
            child: Text(controller.processedText.value!.total.toString()),
          );
        },
=======
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
        child: Column(
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
                      height: 120, // Perbesar agar nama terlihat dengan baik
                      child: ListView(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              return ParticipantItem(
                                isLast: participants.length == 1,
                                imgPath: participants[index]['image'],
                                name: participants[index]['name'],
                                isSelected: selectedIndex == index,
                                onSelected: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                onNameChanged: (newName) {
                                  setState(() {
                                    participants[index]['name'] = newName;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    participants.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: addParticipant,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.withAlpha(120),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'JOHOR BAHRU RESTORANT',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tagihan dibuat: 27/10/1019 13:00',
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
                      itemCount: people[0].listMenuItems.length,
                      itemBuilder: (context, index) {
                        final item = people[0].listMenuItems[index];
                        return getListMenu(
                          item,
                          selectedItem.contains(item),
                          () => doMultiSelection(item),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          rowText('Subtotal', 'IDR 58.000'),
                          rowText('Pajak', 'IDR 5.800'),
                          rowText('Layanan', 'IDR 2.500'),
                          rowText('Total Tagihan', 'IDR 66.300', bold: true),
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
        ),
>>>>>>> 6779e272787405bb437f353655cb43207a676bec
      ),
    );
  }
}
<<<<<<< HEAD
=======

class ParticipantItem extends StatefulWidget {
  const ParticipantItem({
    super.key,
    required this.imgPath,
    required this.name,
    this.onTap,
    this.onNameChanged,
    required this.isLast,
    required this.isSelected,
    required this.onSelected,
  });
  final bool isSelected;
  final bool isLast;
  final String imgPath;
  final String name;
  final void Function()? onTap;
  final void Function(String)? onNameChanged;
  final void Function()? onSelected;

  @override
  _ParticipantItemState createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _focusNode = FocusNode();

    // Listener untuk mendeteksi ketika kehilangan fokus
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveAndCloseEditing();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndCloseEditing() {
    setState(() {
      isEditing = false;
    });
    widget.onNameChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.onSelected?.call();
      },
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          widget.isSelected
                              ? Colors.lightGreen
                              : Colors.transparent,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset(
                        widget.imgPath,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: widget.isLast ? null : widget.onTap,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(190),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isEditing = true;
              });
              _focusNode.requestFocus(); // Fokus ke TextField saat diklik
            },
            child:
                isEditing
                    ? SizedBox(
                      width: 80,
                      height: 15,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (value) => _saveAndCloseEditing(),
                      ),
                    )
                    : Text(
                      _controller.text.isEmpty ? "Nama" : _controller.text,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan Menu Items
InkWell getListMenu(MenuItems item, bool isSelected, VoidCallback onTap) {
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
                        item.price,
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
                        item.quantity,
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
                        item.price,
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
>>>>>>> 6779e272787405bb437f353655cb43207a676bec

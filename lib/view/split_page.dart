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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children:
                                participants
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => ParticipantItem(
                                        index: int.parse(
                                          entry.value["image"]
                                              .replaceAll(
                                                "assets/images/profile/image",
                                                "",
                                              )
                                              .replaceAll(".png", ""),
                                        ),
                                        isLast: participants.length == 1,
                                        name:
                                            entry.value["name"], // Nama default
                                        onTap:
                                            () => deleteParticipant(entry.key),
                                        onNameChanged: (newName) {
                                          setState(() {
                                            participants[entry.key]["name"] =
                                                newName;
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 40),
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
      ),
    );
  }
}

class ParticipantItem extends StatefulWidget {
  const ParticipantItem({
    super.key,
    required this.index,
    required this.name,
    this.onTap,
    this.onNameChanged,
    required this.isLast,
  });

  final bool isLast;
  final int index;
  final String name;
  final void Function()? onTap;
  final void Function(String)? onNameChanged;

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
        FocusScope.of(context).unfocus(); // Menutup keyboard saat tap di luar
      },
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/profile/image${widget.index}.png",
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
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

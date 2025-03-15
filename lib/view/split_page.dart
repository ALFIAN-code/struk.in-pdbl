import 'dart:collection';
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

  // Fungsi agar bisa melakukan multi-selection
  void doMultiSelection(MenuItems item) {
    if (selectedItem.contains(item)) {
      selectedItem.remove(item);
    } else {
      selectedItem.add(item);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromRGBO(255, 232, 173, 1.0)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
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

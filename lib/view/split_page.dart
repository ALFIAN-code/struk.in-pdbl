import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/model/menu_items.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  int? selectedIndex; // Lacak index yang dipilih

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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: people[0].listMenuItems.length,
              itemBuilder: (context, index) {
                final item = people[0].listMenuItems[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index; // Set index yang dipilih
                    });
                  },
                  child: listMenu(item, index == selectedIndex, () {
                    setState(() {
                      selectedIndex = null;
                    });
                  }),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  'IDR 58.000',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pajak',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  'IDR 58.000',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  'IDR 58.000',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tagihan',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'IDR 58.000',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget listMenu(MenuItems item, bool isSelected, VoidCallback onRemove) {
  return Card(
    color:
        isSelected
            ? Color.fromRGBO(252, 207, 92, 1.0)
            : Colors.white, // Warna berubah saat dipilih
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    isSelected ? Icons.close : Icons.circle_outlined,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                  iconSize: 20,
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/view/style.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  Map<String, TextEditingController> controllers = {};
  List<Map<String, TextEditingController>> menuControllers = [];

  @override
  void initState() {
    super.initState();

    controllers['restoran'] = TextEditingController(
      text: 'JOHOR BAHRU RESTORANT',
    );
    controllers['tanggal'] = TextEditingController(text: '27/10/2019');

    // 5 dummy item menu
    for (int i = 0; i < 3; i++) {
      final menu = {
        'nama': TextEditingController(text: 'Menu $i'),
        'harga_item': TextEditingController(text: '13000'),
        'kuantitas': TextEditingController(text: '2'),
        'harga': TextEditingController(text: '26000'),
      };

      // Tambahkan listener untuk update otomatis harga total
      menu['harga_item']!.addListener(() => updateHarga(menu));
      menu['kuantitas']!.addListener(() => updateHarga(menu));

      menuControllers.add(menu);
    }
  }

  void updateHarga(Map<String, TextEditingController> menu) {
    final hargaItem = int.tryParse(menu['harga_item']!.text) ?? 0;
    final kuantitas = int.tryParse(menu['kuantitas']!.text) ?? 0;
    final totalHarga = hargaItem * kuantitas;
    setState(() {
      menu['harga']!.text = totalHarga.toString();
    });
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    for (var menu in menuControllers) {
      menu.forEach((key, controller) => controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Struk',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kamu bisa mengubah nama struk, nama menu, harga, kuantitas, serta pajak di struk ini.',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                const SizedBox(height: 20),
                buildTextField(
                  controller: controllers['restoran']!,
                  hintText: 'Nama Struk',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                buildTextField(
                  controller: controllers['tanggal']!,
                  hintText: 'Tanggal Struk',
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 35),
                Divider(color: borderColor, thickness: 1),
                Column(
                  children: List.generate(menuControllers.length, (index) {
                    final menu = menuControllers[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                controller: menu['nama']!,
                                hintText: 'Nama Item',
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  menuControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: buildTextField(
                                controller: menu['harga_item']!,
                                hintText: 'Harga/Item',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 80,
                              child: buildQuantity(
                                controller: menu['kuantitas']!,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: buildTextField(
                                controller: menu['harga']!,
                                hintText: 'Total Harga',
                                keyboardType: TextInputType.number,
                                //readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Divider(color: borderColor, thickness: 1),
                        //const SizedBox(height: 5),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: greenColor,
                      child: Icon(Icons.add, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tambah Menu',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // rowText('Subtotal', 'Rp. 0'),
                    Text(
                      'Subtotal',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textGreyColor,
                      ),
                    ),
                    Text(
                      '47.000',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textGreyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pajak',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textGreyColor,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: buildTextField(
                        controller: TextEditingController(text: '4.700'),
                        hintText: 'Pajak',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // rowText('Subtotal', 'Rp. 0'),
                    Text(
                      'Jumlah Total',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '51.700',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                  ), // Jarak dari elemen atasnya
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // aksi konfirmasi
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              252,
                              207,
                              92,
                              1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4, // biar tetap ada bayangan
                          ),
                          child: Text(
                            'Konfirmasi Perubahan',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan text field
  Widget buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(14),
        color: textFieldColor,
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textAlign: textAlign,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 14,
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan text field kuantitas
  Widget buildQuantity({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(14),
        color: textFieldColor,
      ),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 30, color: borderColor),
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                'X',
                style: GoogleFonts.roboto(
                  fontSize: 16, // Ukuran font lebih kecil dari sebelumnya
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

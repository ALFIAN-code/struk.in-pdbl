import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Detail Struk"),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE8AD), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Struk
                // Row(
                //   children: [
                //     IconButton(
                //       onPressed: () {},
                //       icon: Icon(Icons.arrow_back_ios_new_rounded),
                //     ),
                //     Text('Detail Page'),
                //   ],
                // ),
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Icon(Icons.arrow_back_ios_new_rounded),
                  centerTitle: true,
                  title: Text(
                    'Detail Struk',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

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
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/Struk1.png', // Ubah sesuai path gambar struk
                        height: 250,
                        width: width * 0.9,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Informasi Restoran & Tanggal
                Text(
                  "JOHOR BAHRU RESTORANT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "27/10/2019",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                SizedBox(height: 16),

                // Daftar Pesanan
                _buildSectionTitle("Pesanan"),
                _buildOrderItem("NASI GORENG PEDAS", 2, 26900),
                _buildOrderItem("ICE LEMON TEA", 2, 9300),
                _buildOrderItem("NASI GORENG", 2, 22900),

                Divider(thickness: 1),

                // Total Pembayaran
                _buildTotalSection(),

                SizedBox(height: 16),

                // Split Bill
                _buildSectionTitle("Split Bill"),
                _buildSplitBillItem("Raihan", 29000, [
                  _buildSplitOrder("NASI GORENG PEDAS", 1, 13400),
                  _buildSplitOrder("ICE LEMON TEA", 1, 9300),
                  _buildSplitOrder("NASI GORENG", 1, 11000),
                ]),
                _buildSplitBillItem("Hilmi", 29000, [
                  _buildSplitOrder("NASI GORENG PEDAS", 1, 13400),
                  _buildSplitOrder("ICE LEMON TEA", 1, 9300),
                  _buildSplitOrder("NASI GORENG", 1, 11000),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderItem(String name, int qty, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("$name      $qty x"), Text("Rp ${price * qty}")],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRow("Subtotal", 47100),
        _buildTotalRow("Pajak", 4700),
        Divider(),
        _buildTotalRow("Total", 51700, isBold: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, int amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rp $amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBillItem(String name, int total, List<Widget> orders) {
    return Card(
      color: Colors.yellow[100],
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Text(
                  "$name - IDR $total",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(children: orders),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitOrder(String name, int qty, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("$name     $qty x"), Text("Rp $price")],
      ),
    );
  }
}

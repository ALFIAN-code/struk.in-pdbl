import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/detailpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_model.dart';
import 'package:strukin/view/component/menu_item.dart';
import 'package:strukin/view/fullscreen.dart';

class DetailPage extends StatefulWidget {
  DetailPage({super.key, required this.transaksi});

  final TransaksiModel transaksi;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DetailpageController controller = DetailpageController();

  // late Future<File?> convertedImage;

  @override
  void initState() {
    // convertedImage = Utils.imagehandler(widget.transaksi.imagePath!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // print(
    //   widget.transaksi.detailTransaksis.first.userSplits.first.user?.userID,
    // );
    var groupItemsByUser = controller.groupItemsByUser(widget.transaksi);
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                  ),
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
                SizedBox(height: 10),

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
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(
                              widget.transaksi.imagePath!,
                            ), // Ubah sesuai path gambar struk
                            height: 250,
                            width: width * 0.9,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              Get.to(
                                () => Fullscreen(
                                  file: File(widget.transaksi.imagePath!),
                                ),
                              );
                            },
                            icon: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                Icons.fullscreen,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Informasi Restoran & Tanggal
                Text(
                  widget.transaksi.storeName ?? '-----null-----',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.transaksi.strukDate ?? '-----null-----',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                SizedBox(height: 30),

                // Daftar Pesanan
                // _buildSectionTitle("Pesanan"),
                Column(
                  children:
                      widget.transaksi.detailTransaksis.map((item) {
                        return getListMenu2(
                          item,
                          false,
                          null,
                          isSelectable: false,
                        );
                      }).toList(),
                ),

                SizedBox(height: 30),

                // Total Pembayaran
                _buildTotalSection(widget.transaksi),

                SizedBox(height: 70),

                // Split Bill
                Text(
                  'Split Bill',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children:
                      groupItemsByUser.map((user) {
                        return _buildSplitBillItem(
                          user["username"] ?? "Unknown",
                          user["total_harga"].toInt(),
                          user["items"].map<Widget>((item) {
                            // Pastikan hasilnya List<Widget>
                            return _buildSplitOrder(
                              item["nama_barang"],
                              item["jumlah"],
                              item["harga_per_participant"].toInt(),
                            );
                          }).toList(),
                          user["avatar"],
                        );
                      }).toList(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection(TransaksiModel transaksi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRow("Subtotal", transaksi.subtotal?.toInt() ?? 0),
        _buildTotalRow("Pajak", transaksi.pajak?.toInt() ?? 0),
        Divider(),
        _buildTotalRow("Total", transaksi.total!.toInt(), isBold: true),
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
            Utils.formatCurrency(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBillItem(
    String name,
    int total,
    List<Widget> orders,
    String imgpath,
  ) {
    return Card(
      color: Colors.white,
      // elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(imgpath, width: 40, height: 40, fit: BoxFit.cover),

                SizedBox(width: 10),
                Text(
                  "$name - ${Utils.formatCurrency(total)}",
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
        children: [Text(name), Text(Utils.formatCurrency(price))],
      ),
    );
  }
}

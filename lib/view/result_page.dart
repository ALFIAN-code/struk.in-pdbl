import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/result_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/view/Homepage.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.transaksiID});
  final int transaksiID;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  var resultController = Get.put(ResultController());

  @override
  void initState() {
    super.initState();
    // Fetch transaksi; grouping nanti di‐build()
    resultController.getTransaksi(widget.transaksiID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Obx(
          () => Text(
            resultController.transaksi.value?.storeName?.toUpperCase() ??
                "STORE NAME",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final tx = resultController.transaksi.value;
          if (tx == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // ——— Hitung grouping **setelah** tx ada ———
          final groupedData = resultController.groupItemsByUser(tx);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.storeName?.toUpperCase() ?? "NAMA RESTORAN",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Tagihan dibuat: ${tx.strukDate}",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 10),
                ...groupedData.map((entry) {
                  final username = entry["username"] as String;
                  final avatar = entry["avatar"] as String;
                  final totalharga = entry["total_harga"] as double;
                  final items = entry["items"] as List<Map<String, dynamic>>;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(avatar),
                          ),
                          title: Text(
                            "Total tagihan $username",
                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                          subtitle: Text(
                            Utils.formatCurrency(totalharga.toInt()),
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = items[itemIndex];
                            final nama = item["nama_barang"] as String;
                            final qty = item["jumlah"] as double;
                            final hargaPP =
                                item["harga_per_participant"] as double;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$nama",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text('x$qty'),
                                  Expanded(
                                    child: Text(
                                      Utils.formatCurrency(hargaPP.toInt()),
                                      style: GoogleFonts.roboto(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pajak', style: GoogleFonts.roboto(fontSize: 16)),
                    Text(
                      Utils.formatCurrency(tx.pajak?.toInt() ?? 0),
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ],
                ),
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
                      Utils.formatCurrency(tx.total?.toInt() ?? 0),
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.off(HomePage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(252, 207, 92, 1.0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Selesai',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

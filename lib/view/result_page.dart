import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/result_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';
import 'package:strukin/view/Homepage.dart';

class ResultPage extends StatefulWidget {
  final TransaksiModel transaksiModel;

  const ResultPage({Key? key, required this.transaksiModel}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late List<Map<String, dynamic>> groupedData;
  var resultController = Get.put(ResultController());

  @override
  void initState() {
    super.initState();
    // resultController.GetTransaksi(widget.idTransaksi);
    groupedData = resultController.groupItemsByUser(widget.transaksiModel);
  }

  @override
  Widget build(BuildContext context) {
    print(groupedData);
    print(widget.transaksiModel.toMap());
    print(widget.transaksiModel.detailTransaksis.first.toMap);
    // return Center(child: Text('Result Page'));

    // final totalKeseluruhan = widget.transaksiModel.total ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.off(HomePage());
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          widget.transaksiModel.storeName ?? "Store Name",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(255, 232, 173, 1.0),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.transaksiModel.storeName?.toUpperCase() ??
                    "NAMA RESTORAN",
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Tagihan dibuat: ${widget.transaksiModel.strukDate ?? ''}",
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              ...groupedData.map((entry) {
                final username = entry["username"] as String;
                final items =
                    entry["items"] as List<Map<String, dynamic>>? ?? [];
                final avatar = entry["avatar"] as String;
                final totalharga = entry["total_harga"] as double;

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
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item["nama_barang"],
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(0, 0, 0, 1.0),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${item["jumlah"]}x",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: const Color.fromRGBO(
                                        90,
                                        90,
                                        90,
                                        1.0,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    Utils.formatCurrency(
                                      item["harga_per_participant"].toInt(),
                                    ),
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: const Color.fromRGBO(
                                        40,
                                        40,
                                        40,
                                        1.0,
                                      ),
                                    ),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pajak',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    Utils.formatCurrency(widget.transaksiModel.pajak!.toInt()),
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
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
                    'IDR ${widget.transaksiModel.total!.toStringAsFixed(0)}',
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.off(HomePage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(252, 207, 92, 1.0),
            ),
            child: Text(
              'Selesai',
              style: GoogleFonts.roboto(
                fontSize: 18,
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

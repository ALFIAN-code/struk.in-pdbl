import 'package:flutter/material.dart';
import 'package:strukin/database/database_helper.dart';
import 'package:strukin/model/struk_model.dart';

class FullTransaksiPage extends StatefulWidget {
  const FullTransaksiPage({Key? key}) : super(key: key);

  @override
  _FullTransaksiPageState createState() => _FullTransaksiPageState();
}

class _FullTransaksiPageState extends State<FullTransaksiPage> {
  late Future<List<TransaksiModel>> _futureTransaksi;

  @override
  void initState() {
    super.initState();
    _futureTransaksi = DatabaseHelper().getAllTransaksiWithDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Full Transaksi")),
      body: FutureBuilder<List<TransaksiModel>>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data transaksi tidak tersedia"));
          } else {
            List<TransaksiModel> transaksiList = snapshot.data!;
            return ListView.builder(
              itemCount: transaksiList.length,
              itemBuilder: (context, index) {
                TransaksiModel transaksi = transaksiList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text("Transaksi ID: ${transaksi.transaksiID}"),
                    subtitle: Text(
                      "Store: ${transaksi.storeName}\nTotal: ${transaksi.total}",
                    ),
                    children:
                        transaksi.detailTransaksis.map((detail) {
                          detail.userSplits.forEach((split) {
                            print("User: ${split.user?.username ?? 'Unknown'}");
                          });
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ExpansionTile(
                              title: Text("Item: ${detail.namaBarang}"),
                              subtitle: Text(
                                "Harga: ${detail.harga} | Jumlah: ${detail.jumlah}",
                              ),
                              children:
                                  (detail.userSplits.isEmpty)
                                      ? [Text('kosong')]
                                      : detail.userSplits.map((split) {
                                        return ListTile(
                                          title: Text(
                                            "User: ${split.user?.username ?? 'Unknown'}",
                                          ),
                                          subtitle: Text(
                                            "Portion: ${split.portion}",
                                          ),
                                        );
                                      }).toList(),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

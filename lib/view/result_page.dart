// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:strukin/model/struk_from_api.dart';

// class ResultPage extends StatefulWidget {
//   const ResultPage({super.key});

//   @override
//   State<ResultPage> createState() => _ResultPageState();
// }

// class _ResultPageState extends State<ResultPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('test'),
//         backgroundColor: Color.fromRGBO(255, 232, 173, 1.0),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromRGBO(255, 232, 173, 1.0),
//               Color.fromRGBO(255, 255, 255, 0),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             stops: [0.3, 1.0],
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'JOHOR BAHRU RESTORANT',
//               style: GoogleFonts.roboto(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               'Tagihan dibuat: 27/10/1019 13:00',
//               style: GoogleFonts.roboto(
//                 fontSize: 14,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//             SizedBox(height: 10),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: people.length,
//               itemBuilder: (context, personIndex) {
//                 final person = people[personIndex];
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       leading: CircleAvatar(backgroundColor: Colors.amber),
//                       title: Text(
//                         'Total tagihan ${person.name}',
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                       subtitle: Text(
//                         'IDR 29.000',
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       dense: true,
//                     ),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics:
//                           NeverScrollableScrollPhysics(), // Biar scroll ga bentrok
//                       itemCount: person.listMenuItems.length,
//                       itemBuilder: (context, itemIndex) {
//                         final item = person.listMenuItems[itemIndex];
//                         return Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               flex: 3,
//                               child: Text(
//                                 item.name,
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color.fromRGBO(0, 0, 0, 1.0),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Text(
//                                 item.quantity,
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.normal,
//                                   color: Color.fromRGBO(90, 90, 90, 1.0),
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 item.price,
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.normal,
//                                   color: Color.fromRGBO(40, 40, 40, 1.0),
//                                 ),
//                                 textAlign: TextAlign.right,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                     SizedBox(height: 20),
//                   ],
//                 );
//               },
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total Tagihan',
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'IDR 58.000',
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color.fromRGBO(252, 207, 92, 1.0),
//                 ),
//                 child: Text(
//                   'Selesai',
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ExpansionTile(
                              title: Text("Item: ${detail.namaBarang}"),
                              subtitle: Text(
                                "Harga: ${detail.harga} | Jumlah: ${detail.jumlah}",
                              ),
                              children:
                                  detail.userSplits.map((split) {
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

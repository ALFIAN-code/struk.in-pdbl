import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/utils.dart';

class SplitUser extends StatelessWidget {
  const SplitUser({
    super.key,
    required this.avatar,
    required this.username,
    required this.totalharga,
    required this.items,
  });

  final String avatar;
  final String username;
  final double totalharga;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,

            itemBuilder: (context, itemIndex) {
              final item = items[itemIndex];
              final nama = item["nama_barang"] as String;
              final qty = item["portion"] as double;
              final hargaPP = item["share_price"] as double;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                    Text('x${qty.toInt()}'),
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
  }
}

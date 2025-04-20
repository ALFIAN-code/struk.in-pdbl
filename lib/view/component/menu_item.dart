/// Komponen untuk menampilkan item menu dalam daftar
///
/// Berisi:
/// - getListMenu: Widget untuk menampilkan item menu dengan opsi seleksi
/// - getListMenu2: Widget alternatif untuk menampilkan item menu
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/model/struk_model.dart';

/// Widget untuk menampilkan item menu dengan opsi seleksi
///
/// [item] - Data item yang akan ditampilkan
/// [isSelected] - Status seleksi item
/// [onTap] - Callback ketika item di-tap
/// [isSelectable] - Flag apakah item bisa dipilih
///
/// Mengembalikan:
/// - Widget InkWell yang berisi tampilan item menu
// InkWell getListMenu(
// Item item,
// bool? isSelected,
// VoidCallback? onTap, {
// bool isSelectable = true,
// }) {
//   var splitController = Get.find<SplitpageController>();

//   var participantWhoSelected = splitController.getParticipantsWhoSelectedItem(
//     item,
//   );
// }

class GetListMenu extends StatefulWidget {
  GetListMenu({
    super.key,
    required this.item,
    required this.isSelectable,
    required this.isSelected,
    required this.onTap,
    required this.taxPercentage,
  });

  final Item item;
  bool isSelected;
  final VoidCallback? onTap;
  final bool isSelectable;
  bool isExpand = false;
  final double taxPercentage;

  @override
  State<GetListMenu> createState() => _GetListMenuState();
}

class _GetListMenuState extends State<GetListMenu> {
  var splitController = Get.find<SplitpageController>();

  @override
  Widget build(BuildContext context) {
    var participantWhoSelected = splitController.getParticipantsWhoSelectedItem(
      widget.item,
    );

    int taxPerMenu =
        (widget.item.unitPrice! * (widget.taxPercentage / 100)).round();

    return GestureDetector(
      onTap: widget.isSelectable ? widget.onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color:
              widget.isSelectable
                  ? widget.isSelected
                      ? Color(0xffFDE2A1)
                      : Colors.transparent
                  : Colors.transparent,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name ?? ' ',
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
                      child: Row(
                        children: [
                          Text(
                            Utils.formatCurrency(widget.item.unitPrice ?? 0),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: const Color.fromRGBO(40, 40, 40, 1.0),
                            ),
                          ),
                          (splitController.includePajak.value)
                              ? Text(
                                ' + ${Utils.formatCurrency(taxPerMenu, withSymbol: false)}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.item.quantity}X',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(90, 90, 90, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Utils.formatCurrency(
                          (splitController.includePajak.value)
                              ? (taxPerMenu + widget.item.unitPrice!) *
                                  widget.item.quantity!
                              : widget.item.price!.toInt(),
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color.fromRGBO(40, 40, 40, 1.0),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 10),
                    widget.isSelectable
                        ? Icon(
                          widget.isSelected
                              ? Icons.close
                              : Icons.circle_outlined,
                          size: 20,
                          color: widget.isSelected ? Colors.black : Colors.grey,
                        )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
            (widget.isSelected)
                ? Divider(color: Colors.black.withAlpha(50))
                : SizedBox(),

            GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (participantWhoSelected.isNotEmpty)
                        ? (widget.isExpand)
                            ? SizedBox()
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: Row(
                                    children:
                                        participantWhoSelected.map((e) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 5,
                                            ),
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.orange,
                                              child: Image.asset(
                                                splitController
                                                    .participants
                                                    .value[e]['image'],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            )
                        : SizedBox(),
                    (widget.isSelected)
                        ? GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.isExpand = !widget.isExpand;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                'Sesuaikan Pembagian',
                                style: TextStyle(
                                  color: Colors.black.withAlpha(130),
                                ),
                              ),
                              Icon(
                                widget.isExpand
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                                color: Colors.black.withAlpha(170),
                              ),
                            ],
                          ),
                        )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
            (widget.isExpand)
                ? GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.transparent,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: participantWhoSelected.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.orange,
                                child: Image.asset(
                                  splitController
                                      .participants
                                      .value[participantWhoSelected[index]]['image'],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                splitController
                                    .participants
                                    .value[participantWhoSelected[index]]['name'],
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.black.withAlpha(170),
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  splitController.controlQuantity(
                                    isIncrement: false,
                                    item: widget.item,
                                    participantIndex:
                                        participantWhoSelected[index],
                                  );
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Color(0xffC7AF00),
                                  ),
                                  child: Icon(Icons.remove_rounded),
                                ),
                              ),
                              GetBuilder<SplitpageController>(
                                builder: (controller) {
                                  var quantity =
                                      (splitController
                                                  .participants
                                                  .value[participantWhoSelected[index]]['selectedItems']
                                              as List<Map<String, dynamic>>)
                                          .firstWhere(
                                            (e) =>
                                                (e['item'] as Item).id ==
                                                widget.item.id,
                                          )['quantity'];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Text(quantity.toString()),
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  splitController.controlQuantity(
                                    isIncrement: true,
                                    item: widget.item,
                                    participantIndex:
                                        participantWhoSelected[index],
                                  );
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Color(0xffC7AF00),
                                  ),
                                  child: Icon(Icons.add_rounded),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

/// Widget alternatif untuk menampilkan item menu
///
/// [item] - Data item yang akan ditampilkan (model DetailTransaksiModel)
/// [isSelected] - Status seleksi item
/// [onTap] - Callback ketika item di-tap
/// [isSelectable] - Flag apakah item bisa dipilih
///
/// Mengembalikan:
/// - Widget InkWell yang berisi tampilan item menu
InkWell getListMenu2(
  DetailTransaksiModel item,
  bool? isSelected,
  VoidCallback? onTap, {
  bool isSelectable = true,
}) {
  return InkWell(
    onTap: isSelectable ? onTap : null,
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color:
                isSelectable
                    ? isSelected!
                        ? Color.fromRGBO(252, 207, 92, 1.0)
                        : Colors.transparent
                    : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.namaBarang ?? 'null',
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
                      Utils.formatCurrency(item.hargaSatuan!),
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
                      '${item.jumlah}X',
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
                      Utils.formatCurrency(item.harga!.toInt()),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(40, 40, 40, 1.0),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

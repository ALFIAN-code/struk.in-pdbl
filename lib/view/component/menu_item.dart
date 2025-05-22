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

class GetListMenu extends StatefulWidget {
  GetListMenu({
    super.key,
    required this.participantIndex,
    required this.item,
    required this.isSelectable,
    // required this.isSelected,
    required this.onTap,
  });

  int participantIndex = 0;
  final Item item;
  // bool isSelected;
  final VoidCallback? onTap;
  final bool isSelectable;
  bool isExpand = false;

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

    const int maxAvatars = 5;

    final total = participantWhoSelected.length;
    final displayCount = (total > maxAvatars) ? maxAvatars : total;
    final remaining = total - displayCount;

    final biayaTambahan = splitController.getUnitPrice(widget.item, 
      includeBiayaLainnya: splitController.includeBiayaLainnya.value,
      includeBiayaLayanan: splitController.includeBiayaLayanan.value,
      includeDiskon: splitController.includeDiskon.value,
      includePajak: splitController.includePajak.value
    ) - widget.item.unitPrice!;

    // print('selected = ${widget.isSelected}');
    // print('selected index = ${widget.participantIndex}');
    // print('list participant = ${participantWhoSelected.toList()}');
    
    // var taxPerMenu =
    //     (widget.item.unitPrice! * (widget.taxPercentage / 100)).round();
    return GestureDetector(
      onTap: widget.isSelectable ? widget.onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color:
              widget.isSelectable
                  ? (participantWhoSelected.contains(widget.participantIndex))
                      ? Color(0xffFDE2A1)
                      : Colors.transparent
                  : Colors.transparent,
        ),
        child: Column(
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
                          
                          (splitController.includePajak.value || splitController.includeBiayaLainnya.value || splitController.includeBiayaLayanan.value || splitController.includeDiskon.value)?
                          Text((biayaTambahan >= 0)?' + ':' - ',style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),):SizedBox(),
                          
                          (splitController.includePajak.value || splitController.includeBiayaLainnya.value || splitController.includeBiayaLayanan.value || splitController.includeDiskon.value)
                              ? Text(
                                Utils.formatCurrency(biayaTambahan.abs(), withSymbol: false),
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
                          splitController.getUnitPrice(
                            widget.item,
                            includeBiayaLainnya: splitController.includeBiayaLainnya.value,
                            includeBiayaLayanan: splitController.includeBiayaLayanan.value,
                            includeDiskon: splitController.includeDiskon.value,
                            includePajak: splitController.includePajak.value
                          ) * widget.item.quantity!,
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
                          (participantWhoSelected.contains(
                                widget.participantIndex,
                              ))
                              ? Icons.close
                              : Icons.circle_outlined,
                          size: 20,
                          color:
                              (participantWhoSelected.contains(
                                    widget.participantIndex,
                                  ))
                                  ? Colors.black
                                  : Colors.grey,
                        )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
            (participantWhoSelected.contains(widget.participantIndex))
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
                              children: [
                                // tampilkan avatar untuk index 0 .. displayCount-1
                                for (var i = 0; i < displayCount; i++)
                                  Align(
                                    // padding: const EdgeInsets.only(right: 5),
                                    widthFactor: 1.2,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.orange,
                                      child: Image.asset(
                                        splitController
                                            .participants
                                            .value[participantWhoSelected[i]]['image'],
                                      ),
                                    ),
                                  ),
                                // kalau ada sisa, tampilkan +N
                                (remaining > 0)
                                    ? Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey.shade300,
                                        child: Text(
                                          '+$remaining',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )
                                    : SizedBox(),
                              ],
                            )
                        : SizedBox(),
                    (participantWhoSelected.contains(widget.participantIndex))
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

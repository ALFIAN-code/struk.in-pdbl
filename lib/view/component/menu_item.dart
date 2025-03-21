// Widget untuk menampilkan Menu Items
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/model/struk_model.dart';

InkWell getListMenu(
  Item item,
  bool? isSelected,
  VoidCallback? onTap, {
  bool isSelectable = true,
}) {
  var splitController = Get.find<SplitpageController>();

  var participantWhoSelected = splitController.getParticipantsWhoSelectedItem(
    item,
  );

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
                item.name,
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
                      Utils.formatCurrency(item.unitPrice),
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
                      '${item.quantity}X',
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
                      Utils.formatCurrency(item.price.toInt()),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromRGBO(40, 40, 40, 1.0),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  isSelectable
                      ? Visibility(
                        child: Icon(
                          isSelected! ? Icons.close : Icons.circle_outlined,
                          size: 20,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      )
                      : SizedBox(),
                ],
              ),
              (participantWhoSelected.isNotEmpty)
                  ? SizedBox(
                    height: 30,
                    child: Row(
                      children:
                          participantWhoSelected.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5),
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
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ],
    ),
  );
}

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

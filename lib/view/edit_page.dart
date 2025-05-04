import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:strukin/controller/edit_page_controller.dart';
import 'package:strukin/controller/splitpage_controller.dart';
import 'package:strukin/controller/utils.dart';
import 'package:strukin/model/struk_from_api.dart';
import 'package:strukin/view/style.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  var editController = Get.put(EditPageController());
  var splitController = Get.put(SplitpageController());

  @override
  Widget build(BuildContext context) {
    var date = DateTime.parse(editController.transaksi.value!.date!);
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubah Struk',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kamu bisa mengubah nama struk, nama menu, harga, kuantitas, serta pajak di struk ini.',
                      maxLines: 3,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                BuildTextField(
                  editPageController: editController,
                  data: editController.transaksi.value!.businessName.toString(),
                  isString: true,
                  onChanged: (value) {
                    editController.transaksi.value!.businessName = value;
                  },
                  hintText: 'Nama Struk',

                  keyboardType: TextInputType.text,
                  textstyle: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: BuildTextField(
                        label: 'Tanggal',
                        editPageController: editController,
                        data: '${date.day}-${date.month}-${date.year}',
                        isString: true,

                        hintText: 'Tanggal Struk',
                        readOnly: true,
                        onTap: () async {
                          var date = DateTime.parse(
                            editController.transaksi.value!.date!,
                          );
                          var picked = await showDatePicker(
                            context: context,
                            initialDate: date,

                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null && picked != date) {
                            var result = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              date.hour,
                              date.minute,
                            );
                            setState(() {
                              editController.transaksi.value!.date = DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(result);
                            });
                          }
                          editController.transaksi.refresh();
                        },
                        keyboardType: TextInputType.datetime,
                        textstyle: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff5A5A5A),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 75,
                      child: BuildTextField(
                        label: 'Jam',
                        editPageController: editController,
                        data:
                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        isString: true,

                        hintText: 'Tanggal Struk',
                        readOnly: true,
                        onTap: () async {
                          var picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: date.hour,
                              minute: date.minute,
                            ),
                          );
                          if (picked != null && picked != date) {
                            var result = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              picked.hour,
                              picked.minute,
                            );
                            setState(() {
                              editController.transaksi.value!.date = DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(result);
                            });
                          }
                          editController.transaksi.refresh();
                        },
                        keyboardType: TextInputType.datetime,
                        textstyle: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff5A5A5A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Divider(color: borderColor, thickness: 1),
                Obx(
                  () => Column(
                    children: List.generate(editController.transaksi.value!.items!.length, (
                      index,
                    ) {
                      print('rebuild');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BuildTextField(
                                  editPageController: editController,
                                  data:
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .name
                                          .toString(),
                                  isString: true,
                                  onChanged: (value) {
                                    editController
                                        .transaksi
                                        .value!
                                        .items![index]
                                        .name = value;
                                    print(
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .name,
                                    );
                                  },
                                  hintText: 'Nama Item',
                                  textstyle: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    editController.transaksi.value!.items!
                                        .removeAt(index);
                                    editController.updateTotal();
                                    splitController.processedText.refresh();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: BuildTextField(
                                  editPageController: editController,
                                  data:
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .unitPrice
                                          .toString(),
                                  isString: false,
                                  onChanged: (value) {
                                    editController
                                        .transaksi
                                        .value!
                                        .items![index]
                                        .unitPrice = int.tryParse(value);

                                    editController.total(index);
                                    editController.transaksi.refresh();
                                    editController.updateTotal();
                                    print(
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .unitPrice,
                                    );
                                  },
                                  hintText: 'Harga/Item',
                                  keyboardType: TextInputType.number,

                                  label: 'Harga Item',
                                  textstyle: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff5A5A5A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (editController
                                            .transaksi
                                            .value!
                                            .items![index]
                                            .quantity! >
                                        1) {
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .quantity = editController
                                              .transaksi
                                              .value!
                                              .items![index]
                                              .quantity! -
                                          1;
                                      editController.total(index);
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .price = editController
                                              .transaksi
                                              .value!
                                              .items![index]
                                              .unitPrice ??
                                          0 *
                                              editController
                                                  .transaksi
                                                  .value!
                                                  .items![index]
                                                  .quantity!;
                                      editController.updateTotal();
                                      editController.transaksi.refresh();
                                      print(
                                        '${editController.transaksi.value!.items![index].quantity}',
                                      );
                                      print(
                                        '${editController.transaksi.value!.items![index].unitPrice}',
                                      );
                                      print(
                                        '${editController.transaksi.value!.items![index].price}',
                                      );
                                    }
                                  });
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
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Text(
                                      editController
                                          .transaksi
                                          .value!
                                          .items![index]
                                          .quantity
                                          .toString(),
                                    ),
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    editController
                                        .transaksi
                                        .value!
                                        .items![index]
                                        .quantity = editController
                                            .transaksi
                                            .value!
                                            .items![index]
                                            .quantity! +
                                        1;
                                    editController.total(index);
                                    editController
                                        .transaksi
                                        .value!
                                        .items![index]
                                        .price = editController
                                            .transaksi
                                            .value!
                                            .items![index]
                                            .unitPrice! *
                                        editController
                                            .transaksi
                                            .value!
                                            .items![index]
                                            .quantity!;
                                    editController.updateTotal();
                                    editController.transaksi.refresh();
                                    print(
                                      '${editController.transaksi.value!.items![index].quantity}',
                                    );
                                    print(
                                      '${editController.transaksi.value!.items![index].unitPrice}',
                                    );
                                    print(
                                      '${editController.transaksi.value!.items![index].price}',
                                    );
                                  });
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
                              const SizedBox(width: 30),

                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: Text(
                                  Utils.formatCurrency(
                                    editController
                                        .transaksi
                                        .value!
                                        .items![index]
                                        .price!,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Divider(color: borderColor, thickness: 1),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        editController.addMenu(
                          Item(
                            id:
                                editController.transaksi.value!.items!.length +
                                1,
                            name: 'nama menu',
                            quantity: 1,
                            price: 0,
                            unitPrice: 0,
                          ),
                        );
                        editController.updateTotal();
                        editController.transaksi.refresh();
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            'Tambah Menu',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: greenColor,
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subtotal',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textGreyColor,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        Utils.formatCurrency(
                          editController.transaksi.value!.subtotal!,
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textGreyColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pajak',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textGreyColor,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: BuildTextField(
                        editPageController: editController,
                        data: editController.transaksi.value!.tax.toString(),
                        onChanged: (value) {
                          editController.updateTax(int.parse(value));
                          editController.transaksi.refresh();
                        },
                        isString: false,
                        hintText: 'Pajak',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        textstyle: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textGreyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Jumlah Total',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        Utils.formatCurrency(
                          editController.transaksi.value!.total!,
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                  ), // Jarak dari elemen atasnya
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFFFBF2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 1, // biar tetap ada bayangan
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            splitController.updateData(
                              editController.transaksi.value!,
                            );
                            splitController.processedText.refresh();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              252,
                              207,
                              92,
                              1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 1, // biar tetap ada bayangan
                          ),
                          child: Text(
                            'Konfirmasi',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildTextField extends StatefulWidget {
  final String? hintText;
  final TextInputType keyboardType;
  final bool isString;
  final bool readOnly;
  final int maxLines;
  final TextAlign textAlign;
  final void Function(String)? onChanged;
  String data;
  TextStyle? textstyle;
  String? label;

  EditPageController editPageController;

  void Function()? onTap;

  BuildTextField({
    super.key,
    required this.data,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.isString = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.textstyle,
    this.label,
    this.onTap,
    required this.editPageController,
  });

  @override
  State<BuildTextField> createState() => _BuildTextFieldState();
}

class _BuildTextFieldState extends State<BuildTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.data;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BuildTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _controller.text = widget.data;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      inputFormatters:
          widget.isString
              ? null
              : [
                CurrencyTextInputFormatter.currency(),
                LengthLimitingTextInputFormatter(15),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
      style: widget.textstyle,
      onTap: widget.onTap,
      decoration: InputDecoration(
        // prefix: (widget.isString) ? null : Text('IDR '),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor),
        ),
        isDense: true,
        filled: true,
        label: (widget.label != null) ? Text(widget.label ?? '') : null,
        labelStyle: TextStyle(color: Colors.black45),
        fillColor: textFieldColor,

        hintText: widget.hintText,
        hintStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      ),
    );
  }
}

class buildQuantity extends StatefulWidget {
  final void Function(String)? onChanged;

  String data;

  buildQuantity({required this.data, super.key, required this.onChanged});

  @override
  State<buildQuantity> createState() => _buildQuantityState();
}

class _buildQuantityState extends State<buildQuantity> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _controller.text = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(14),
        color: textFieldColor,
      ),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 30, color: borderColor),
          const SizedBox(
            width: 30,
            child: Center(
              child: Text(
                'X',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

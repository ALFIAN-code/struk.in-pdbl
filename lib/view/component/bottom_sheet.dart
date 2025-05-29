import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/home_controller.dart';
import 'package:strukin/model/category_enum.dart';
import 'package:strukin/view/style.dart';

class FilterButtomSheet extends StatefulWidget {
  const FilterButtomSheet({super.key});

  @override
  State<FilterButtomSheet> createState() => _FilterButtomSheetState();
}

class _FilterButtomSheetState extends State<FilterButtomSheet> {
  var enumCategory = CategoryStruk.values.map((e) => e.label).toList();
  // String selectedCategory = 'Semua';
  final controller = Get.find<HomepageController>();

  // String selectedTime = 'Scan terbaru';
  var timeList = [
    'Scan terbaru',
    'Scan terlama',
    'Struk terbaru',
    'Struk terlama',
  ];

  Widget buildChips(
    List<String> options,
    String selected,
    Function(String) onSelected,
  ) {
    return Wrap(
      spacing: 8,
      children:
          options.map((label) {
            final isSelected = selected == label;
            return ChoiceChip(
              label: Text(label),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(label),
              selectedColor: accentColor.withAlpha(200),
              backgroundColor: Colors.black.withAlpha(20),
              labelStyle: TextStyle(color: Colors.black87),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var selectedCategory = controller.selectedCategory.value;
    // var selectedTime = controller.selectedTime.value;

    var filterCategory = [...enumCategory, 'Semua'];
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(30, 10, 15, 0),
      // height: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.close, size: 25, color: Colors.black),
              ),
            ],
          ),
          Text(
            'Kategori',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10),
          buildChips(filterCategory, controller.selectedCategory.value, (val) {
            setState(() {
              controller.selectedCategory.value = val;
              controller.applyFilters();
            });
          }),
          SizedBox(height: 20),
          Text(
            'Waktu',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10),
          buildChips(timeList, controller.selectedTime.value, (val) {
            setState(() {
              controller.selectedTime.value = val;
              controller.applyFilters();
            });
          }),
          // Expanded(child: SizedBox()),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

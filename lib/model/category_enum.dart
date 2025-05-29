import 'package:flutter/material.dart';

enum CategoryStruk {
  makanan("Makanan", Colors.red),
  belanja("Belanja", Colors.green),
  transportasi("Transportasi", Colors.blue),
  hiburan("Hiburan", Colors.purple),
  lainnya("Lainnya", Colors.grey);

  final String label;
  final Color color;

  const CategoryStruk(this.label, this.color);

  static CategoryStruk fromLabel(String? label) {
    if (label == null || label.trim().isEmpty) {
      return CategoryStruk.lainnya;
    }

    return CategoryStruk.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => CategoryStruk.lainnya,
    );
  }
}

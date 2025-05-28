import 'package:flutter/material.dart';

enum Category {
  makanan("Makanan", Colors.red),
  belanja("Belanja", Colors.green),
  transportasi("Transportasi", Colors.blue),
  hiburan("Hiburan", Colors.purple),
  lainnya("Lainnya", Colors.grey);

  final String label;
  final Color color;

  const Category(this.label, this.color);

  static Category fromLabel(String? label) {
    if (label == null || label.trim().isEmpty) {
      return Category.lainnya;
    }

    return Category.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => Category.lainnya,
    );
  }
}

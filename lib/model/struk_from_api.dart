class StrukFromApi {
  // String? paymentMethod;
  bool? isStruk;
  String? invoiceNumber;
  String? date;
  List<Item>? items;
  int? subtotal;
  int? tax;
  int? total;
  String? businessName;
  String category;
  int? diskon;
  int? biayaLayanan;
  int? biayaLainnya;

  StrukFromApi({
    required this.isStruk,
    required this.date,
    required this.invoiceNumber,
    required this.businessName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.category,
    required this.diskon,
    required this.biayaLainnya,
    required this.biayaLayanan,
  });

  factory StrukFromApi.fromJson(Map<String, dynamic> json) {
    return StrukFromApi(
      isStruk: json['is_struk'],
      date: json['date'],
      invoiceNumber: json['invoice_number'],
      items:
          (json['items'] as List<dynamic>)
              .map((itemJson) => Item.fromJson(itemJson))
              .toList(),
      subtotal: json['subtotal'],
      tax: json['tax'] ?? 0,
      total: json['total'],
      businessName: json['business_name'].toUpperCase(),
      category: json['category'] ?? 'unknown',
      diskon: json['diskon'] ?? 0,
      biayaLayanan: json['biaya_layanan'] ?? 0,
      biayaLainnya: json['biaya_lainnya'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'invoice_number': invoiceNumber,
      'date': date,
      'business_name': businessName,
      'category': category,
      'diskon': diskon,
      'biaya_layanan': biayaLayanan,
      'biaya_lainnya': biayaLainnya,
    };
  }

  StrukFromApi copyWith({
    List<Item>? items,
    int? subtotal,
    int? tax,
    int? total,
    bool? isStruk,
    String? invoiceNumber,
    String? date,
    String? paymentMethod,
  }) {
    return StrukFromApi(
      isStruk: isStruk ?? this.isStruk,
      date: date ?? this.date,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      // paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      businessName: businessName,
      category: category,
      diskon: diskon,
      biayaLainnya: biayaLainnya,
      biayaLayanan: biayaLayanan,
    );
  }

  /// Deep copy helper to clone all nested objects
  StrukFromApi deepCopy() {
    return StrukFromApi(
      isStruk: isStruk,
      invoiceNumber: invoiceNumber,
      businessName: businessName,
      date: date,
      subtotal: subtotal,
      tax: tax,
      total: total,
      items: items?.map((item) => item.deepCopy()).toList(),
      category: category,
      diskon: diskon,
      biayaLainnya: biayaLainnya,
      biayaLayanan: biayaLayanan,
    );
  }

  @override
  String toString() {
    return 'Order(items: $items, subtotal: $subtotal, tax: $tax, total: $total, invoiceNumber: $invoiceNumber, date: $date,)';
  }
}

class Item {
  int id;
  String? name;
  int? quantity;
  int? price;
  // String category;
  int? unitPrice;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.unitPrice,
    // required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      unitPrice: json['unit_price'].toInt(),
      name: json['name'],
      quantity: json['quantity'].toInt(),
      price:
          json['price_total'] is double
              ? json['price_total'].toInt()
              : json['price_total'],
      // category: json['category'].toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price_total': price,
      // 'category': category.toLowerCase(),
    };
  }

  Item copyWith({
    String? name,
    int? quantity,
    int? price,
    String? category,
    int? unitPrice,
    int? id,
  }) {
    return Item(
      id: id ?? this.id,
      unitPrice: unitPrice ?? this.unitPrice,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  /// Deep copy helper to clone this item
  Item deepCopy() {
    return Item(
      id: id,
      name: name,
      quantity: quantity,
      price: price,
      unitPrice: unitPrice,
    );
  }

  @override
  String toString() {
    return 'Item(name: $name, quantity: $quantity, price: $price,)';
  }
}

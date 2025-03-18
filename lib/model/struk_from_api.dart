class StrukFromApi {
  // String? paymentMethod;
  String? invoiceNumber;
  String? date;
  List<Item>? items;
  int? subtotal;
  int? tax;
  int? total;
  String businessName;
  String category;

  StrukFromApi({
    required this.date,
    required this.invoiceNumber,
    // required this.paymentMethod,
    required this.businessName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.category,
  });

  factory StrukFromApi.fromJson(Map<String, dynamic> json) {
    return StrukFromApi(
      date: json['date'],
      invoiceNumber: json['invoice_number'],
      // paymentMethod: json['payment_method'].toString().toUpperCase(),
      items:
          (json['items'] as List<dynamic>)
              .map((itemJson) => Item.fromJson(itemJson))
              .toList(),
      subtotal: json['subtotal'],
      tax: json['tax'] ?? 0,
      total: json['total'],
      businessName: json['business_name'],
      category: json['category'],
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
      // 'payment_method': paymentMethod?.toUpperCase(),
    };
  }

  StrukFromApi copyWith({
    List<Item>? items,
    int? subtotal,
    int? tax,
    int? total,
    String? invoiceNumber,
    String? date,
    String? paymentMethod,
  }) {
    return StrukFromApi(
      date: date ?? this.date,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      // paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      businessName: businessName,
      category: category,
    );
  }

  @override
  String toString() {
    return 'Order(items: $items, subtotal: $subtotal, tax: $tax, total: $total, invoiceNumber: $invoiceNumber, date: $date,)';
  }
}

class Item {
  String name;
  int quantity;
  double price;
  // String category;
  int unitPrice;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.unitPrice,
    // required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      unitPrice: json['unit_price'].toInt(),
      name: json['name'].toLowerCase(),
      quantity: json['quantity'].toInt(),
      price:
          (json['price_total'].runtimeType != String)
              ? json['price_total'].toDouble()
              : 0, // Ensures correct parsing for non-string price fields
      // category: json['category'].toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price_total': price,
      // 'category': category.toLowerCase(),
    };
  }

  Item copyWith({
    String? name,
    int? quantity,
    double? price,
    String? category,
    int? unitPrice,
  }) {
    return Item(
      unitPrice: unitPrice ?? this.unitPrice,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      // category: (category ?? this.category).toLowerCase(),
    );
  }

  @override
  String toString() {
    return 'Item(name: $name, quantity: $quantity, price: $price,)';
  }
}

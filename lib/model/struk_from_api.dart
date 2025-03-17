class StrukFromApi {
  // String? paymentMethod;
  String? invoiceNumber;
  String? date;
  List<Item>? items;
  double? subtotal;
  double? tax;
  double? total;

  StrukFromApi({
    required this.date,
    required this.invoiceNumber,
    // required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
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
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
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
      // 'payment_method': paymentMethod?.toUpperCase(),
    };
  }

  StrukFromApi copyWith({
    List<Item>? items,
    double? subtotal,
    double? tax,
    double? total,
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
  String category;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'].toInt(),
      price:
          (json['price'].runtimeType != String)
              ? json['price'].toDouble()
              : 0, // Ensures correct parsing for non-string price fields
      category: json['category'].toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category.toLowerCase(),
    };
  }

  Item copyWith({
    String? name,
    int? quantity,
    double? price,
    String? category,
  }) {
    return Item(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: (category ?? this.category).toLowerCase(),
    );
  }

  @override
  String toString() {
    return 'Item(name: $name, quantity: $quantity, price: $price, category: $category)';
  }
}

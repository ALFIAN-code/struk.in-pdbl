import 'package:flutter/material.dart';
import 'package:strukin/model/struk_model.dart';

Widget buildOrderItemsList(Order? processedText) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: processedText?.items.length ?? 0,
    itemBuilder: (context, index) {
      final item = processedText!.items[index];
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item.name),
        subtitle: Text('Quantity: ${item.quantity}'),
        trailing: Text('IDR ${item.price.toStringAsFixed(2)}'),
      );
    },
  );
}

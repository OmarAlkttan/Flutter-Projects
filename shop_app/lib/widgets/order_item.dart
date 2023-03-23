import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/orders.dart' as ord;

class OrderItem extends StatelessWidget {
  final ord.OrderItem orderItem;

  OrderItem(this.orderItem);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('\$${orderItem.amount}'),
        subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(orderItem.dateTime!)),
        children: orderItem.products!.map((prod) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${prod.quantity} x \$${prod.price}'),
              Text('${prod.title}')
            ],
          );
        } ).toList(),
      ),
    );
  }
}

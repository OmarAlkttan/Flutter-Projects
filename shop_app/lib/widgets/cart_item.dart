import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String? id;
  final String? productId;
  final double? price;
  final int? quantity;
  final String? title;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.price,
    @required this.quantity,
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            size: 40,
            color: Colors.white,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeItem(productId!);
        },
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Are you sure!'),
                    content:
                        Text('Do you want to delete this item from the cart ?'),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No')),
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes')),
                    ],
                  ));
        },
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: ListTile(
              subtitle: Text('Total \$${quantity !* price!}'),
              title: Text(title!),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(child: Text('\$$price')),
                ),
              ),
              trailing: Text('$quantity x'),
            ),
          ),
        ));
  }
}

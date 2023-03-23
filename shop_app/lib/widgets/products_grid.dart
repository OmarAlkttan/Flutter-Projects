import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFav;

  ProductsGrid(this.isFav);

  @override
  Widget build(BuildContext context) {
    final prodData = Provider.of<Products>(context);
    final products = isFav ? prodData.FavoriteItems : prodData.items;
    return products.isEmpty
        ? Center(
            child: Text('There is no products now'),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(),
            ),
            itemCount: products.length,
            padding: EdgeInsets.all(8.0),
          );
  }
}

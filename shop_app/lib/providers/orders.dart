import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class OrderItem {
  final String? id;
  final double? amount;
  final DateTime? dateTime;
  final List<CartItem>? products;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;
  var uuid = Uuid();

  getData(String token, String uId, List<OrderItem> orders) {
    authToken = token;
    userId = uId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken';

    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null || extractedData.isEmpty) return;

      List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((product) => CartItem(
                  id: product['id'],
                  title: product['title'],
                  quantity: product['quantity'],
                  price: product['price']))
              .toList(),
        ));
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartItems, double amount) async {
    final timestamp = DateTime.now();
    final url =
        'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': amount,
            'dateTime': timestamp.toIso8601String(),
            'products': cartItems
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: amount,
            dateTime: timestamp,
            products: cartItems,
          ));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

}

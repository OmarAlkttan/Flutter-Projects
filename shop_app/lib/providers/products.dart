import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {

  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
      'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];
  String? authToken;
  String? userId;

  getData(String token, String uId, List<Product> products){
    authToken = token;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get FavoriteItems {
    return _items.where((favProd) => favProd.isFavorite).toList();
  }

  Product findById(String id){
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProduct ([bool filterUsers = false]) async {

    print("userId = $userId");

    final filteredString = filterUsers ? 'orderBy="creatorId"&equalTo="$userId"': '';
    var url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filteredString';

    try{
      final res = await http.get(Uri.parse(url));
      Map<String, dynamic>? extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if(extractedData == null || extractedData.isEmpty) {
        _items = [];
        return;
      }
      url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/userFavorite/$userId.json?auth=$authToken';
      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);

      List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favData == null? false: favData[prodId]?? false,
        ));
        _items = loadedProducts;
        notifyListeners();
      });
    }catch(error){
      throw error;
    }

  }

  Future<void> addProduct(Product product) async {
    final url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken';

    try{
      final res = await http.post(Uri.parse(url), body: json.encode({
        'creatorId': userId,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl
      }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price
      );
      _items.add(newProduct);
      notifyListeners();
    }catch(e){
      throw e;
    }
  }

  Future<void> updateProduct (String id, Product newPrdouct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0){
      final url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
      final res = await http.patch(Uri.parse(url), body: json.encode({
        'title': newPrdouct.title,
        'description': newPrdouct.description,
        'price': newPrdouct.price,
        'imageUrl': newPrdouct.imageUrl,
      }));
      _items[prodIndex] = newPrdouct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct (String id) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProd = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();

    final url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
    final res = await http.delete(Uri.parse(url));
    if(res.statusCode >= 400){
      _items.insert(prodIndex, existingProd);
      notifyListeners();
      throw HttpException("Can't delete this product.");
    }
    existingProd = null;
  }

}
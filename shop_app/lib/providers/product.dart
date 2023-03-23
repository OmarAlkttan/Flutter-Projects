import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false
  });

  bool? _setFavValue (bool newValue){
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus (String token, String userId) async{
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = 'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/isFavorites/$userId/$id.json?auth=$token';
    try{
      final res = await http.put(Uri.parse(url), body: json.encode(isFavorite));
      if(res.statusCode >= 400){
        _setFavValue(oldStatus);
      }
    }catch(error){
      _setFavValue(oldStatus);
    }
  }
}

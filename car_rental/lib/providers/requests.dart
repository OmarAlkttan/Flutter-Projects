import 'package:car_rental/models/http_exception.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

enum RequestState{
  Approved, Waiting, Canceled
}

class Request {
  final String? id;
  final String? renterId;
  final String? ownerId;
  final int? rentPeriod;
  final double? price;
  final String? state;
  final String? renterImageUrl;
  final String? renterName;
  final String? carImageUrl;
  final String? carName;

  Request({
    this.id,
    @required this.renterId,
    @required this.ownerId,
    @required this.rentPeriod,
    @required this.price,
    @required this.state,
    @required this.renterImageUrl,
    @required this.renterName,
    @required this.carImageUrl,
    @required this.carName,
});
}

class Requests with ChangeNotifier{
  List<Request>? _items = [];
  String? authToken;
  String? userId;

  getData(String token, String uId, List<Request> requests) {
    authToken = token;
    userId = uId;
    _items = requests;
    notifyListeners();
  }

  List<Request> get items {
    return [..._items!];
  }

  /*List<Product> get FavoriteItems {
    return _items.where((favProd) => favProd.isFavorite).toList();
  }*/

  Request findById(String id) {
    return _items!.firstWhere((request) => request.id == id);
  }

  Future<void> fetchAndSetOwnerRequests() async {
    _items =[];
    print('inside fetch Owners');
    var url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/requests.json?auth=$authToken&orderBy="ownerId"&equalTo="$userId"';

    try {
      final res = await http.get(Uri.parse(url));
      final Map<String, dynamic>? extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null || extractedData.isEmpty) {
        _items = [];
        return;
      }
      print(extractedData);
      List<Request> loadedRequests = [];
      extractedData.forEach((requestId, requestData) {
        loadedRequests.add(
          Request(
            id: requestId,
            renterId: requestData['renterId'],
            rentPeriod: requestData['rentPeriod'],
            ownerId: requestData['ownerId'],
            price: requestData['price'],
            state: requestData['state'],
            renterImageUrl: requestData['renterImageUrl'],
            renterName: requestData['renterName'],
            carImageUrl: requestData['carImageUrl'],
            carName: requestData['carName'],
          ),
        );
      });
      print('load requests = ${loadedRequests.length}' );
      if(_items!.isEmpty || _items == null){
        print('inside if in the fetch owner');
        _items!.addAll(loadedRequests);
        print(_items!.length);
      }
      loadedRequests.forEach((request) {
        print('hello!');
        if(!(_items!.any((element) {
          print('item id = ${element.id}');
          print('request id = ${request.id}');
          return element.id == request.id;
        }))){
          print('hi!!!!');
          _items!.add(request);
        }
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetRenterRequests() async {
    print('inside fetch Renter');
    var url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/requests.json?auth=$authToken&orderBy="renterId"&equalTo="$userId"';

    try {
      final res = await http.get(Uri.parse(url));
      final Map<String, dynamic>? extractedData = json.decode(res.body) as Map<String, dynamic>;
      if ((extractedData == null || extractedData.isEmpty) && _items!.isEmpty) {
        _items = [];
        return;
      }
      print(extractedData);
      List<Request> loadedRequests = [];
      extractedData!.forEach((requestId, requestData) {
        loadedRequests.add(
          Request(
            id: requestId,
            renterId: requestData['renterId'],
            rentPeriod: requestData['rentPeriod'],
            ownerId: requestData['ownerId'],
            price: requestData['price'],
            state: requestData['state'],
            renterImageUrl: requestData['renterImageUrl'],
            renterName: requestData['renterName'],
            carImageUrl: requestData['carImageUrl'],
            carName: requestData['carName'],
          ),
        );
      });
      if(_items!.isEmpty || _items == null){
        _items!.addAll(loadedRequests);
      }
      print(loadedRequests.length);
      loadedRequests.forEach((request) {
        print('hello!');
        if(!(_items!.any((element) {
          print('item id = ${element.id}');
          print('request id = ${request.id}');
          return element.id == request.id;
        }))){
          print('hi!!!!');
          _items!.add(request);
        }
      });
      print(items.length);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }


  Future<void> addRequest(Request request) async {
    final url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/requests.json?auth=$authToken';

    try {
      final res = await http.post(
        Uri.parse(url),
        body: json.encode({
          'renterId': userId,
          'ownerId': request.ownerId,
          'rentPeriod': request.rentPeriod,
          'price': request.price,
          'state': request.state,
          'renterImageUrl': request.renterImageUrl,
          'renterName': request.renterName,
          'carImageUrl': request.carImageUrl,
          'carName': request.carName,
        }),
      );
      final newRequest = Request(
        id: json.decode(res.body)['name'],
        renterId: userId,
        ownerId: request.ownerId,
        rentPeriod: request.rentPeriod,
        price: request.price,
        state: request.state,
        renterImageUrl: request.renterImageUrl,
        renterName: request.renterName,
        carImageUrl: request.carImageUrl,
        carName: request.carName,
      );
      _items!.add(newRequest);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateRequest(String id, Request newRequest) async {

    final requestIndex = _items!.indexWhere((request) => request.id == id);
    if(requestIndex >= 0){
      final url =
          'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/requests/$id.json?auth=$authToken';
      final res = await http.patch(Uri.parse(url),
        body: json.encode({
          'renterId': newRequest.renterId,
          'ownerId': newRequest.ownerId,
          'rentPeriod': newRequest.rentPeriod,
          'price': newRequest.price,
          'state': newRequest.state,
          'renterImageUrl': newRequest.renterImageUrl,
          'renterName': newRequest.renterName,
          'carImageUrl': newRequest.carImageUrl,
          'carName': newRequest.carName,
        }),);
      _items![requestIndex] = newRequest;

      notifyListeners();
    }else{
      print('Request not found');
    }

  }

  Future<void> deleteRequest(String id) async {
    final requestIndex = _items!.indexWhere((element) => element.id == id);
    Request? existingRequest = _items![requestIndex];
    _items!.removeAt(requestIndex);
    notifyListeners();

    final url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/requests/$id.json?auth=$authToken';
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items!.insert(requestIndex, existingRequest);
      notifyListeners();
      throw HttpException("Can't delete this request.");
    }
    existingRequest = null;
  }


}
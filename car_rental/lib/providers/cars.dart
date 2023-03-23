import 'dart:convert';
import 'dart:io';

import 'package:car_rental/cubit/auth_cubit.dart';
import 'package:car_rental/models/data_provider/authentication.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Car {
  final String? id;
  final String? name;
  final String? model;
  final String? year;
  final String? color;
  final String? description;
  final double? price;
  final String? licenseImageUrl;
  final String? carImageUrl;
  final String? ownerId;

  Car({
    @required this.id,
    @required this.name,
    @required this.model,
    @required this.year,
    @required this.color,
    @required this.description,
    @required this.price,
    @required this.licenseImageUrl,
    @required this.carImageUrl,
    @required this.ownerId,
  });
}

class Cars with ChangeNotifier {
  List<Car> _items = [
    /*Car(
      id: 'c1',
      name: 'Mercedes',
      model: 'CLA 200',
      year: '2021',
      description: 'This car is automatic full motive very stable and new!',
      color: 'black',
      price: 999.99,
      licenseImageUrl:
          'https://image.shutterstock.com/image-vector/car-driver-license-identification-photo-260nw-428314099.jpg',
      carImageUrl:
          'https://media.hatla2eestatic.com/uploads/ncarmodel/7092/big-up_bf59e7ae4a183c88c96f32abb91928c7.png',
      ownerId: '1231546',
    )*/
  ];

  String? authToken;
  String? userId;

  getData(String token, String uId, List<Car> cars) {
    authToken = token;
    userId = uId;
    _items = cars;
    notifyListeners();
  }

  List<Car> get items {
    return [..._items];
  }

  /*List<Product> get FavoriteItems {
    return _items.where((favProd) => favProd.isFavorite).toList();
  }*/

  Car findById(String id) {
    return _items.firstWhere((car) => car.id == id);
  }

  Future<void> fetchAndSetCars({bool filterUsers = false, required String token, required String uId}) async {
    print("inside fetch Cars");
    final filteredString =
        filterUsers ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/cars.json?auth=$authToken&$filteredString';

    try {
      print("inside try");
      final res = await http.get(Uri.parse(url));
      final Map<String, dynamic>? extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null|| extractedData.isEmpty) {
        _items = [];
        return;
      }
      /*url =
          'https://shop-aa241-default-rtdb.europe-west1.firebasedatabase.app/userFavorite/$userId.json?auth=$authToken';
      final favRes = await http.get(url);
      final favData = json.decode(favRes.body);*/

      List<Car> loadedCars = [];
      extractedData.forEach((carId, carData) {
        loadedCars.add(
          Car(
            id: carId,
            name: carData['name'],
            model: carData['model'],
            year: carData['year'],
            price: double.parse(carData['price']),
            description: carData['description'],
            carImageUrl: carData['carImageUrl'],
            /*isFavorite: favData == null ? false : favData[prodId] ?? false,*/
            licenseImageUrl: carData['licenseImageUrl'],
            color: carData['color'],
            ownerId: carData['creatorId']
          ),
        );
      });
      print(_items.length);
      _items.forEach((element) {
        print(element.carImageUrl);
      });
      _items = loadedCars;
      notifyListeners();
    } catch (error) {
      print("inside catch error : $error");
      throw error;
    }
  }

  Future<void> addCar(Car car) async {
    final url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/cars.json?auth=$authToken';

    try {
      final res = await http.post(
        Uri.parse(url),
        body: json.encode({
          'creatorId': userId,
          'name': car.name,
          'model': car.model,
          'price': car.price,
          'year': car.year,
          'color': car.color,
          'description': car.description,
          'carImageUrl': car.carImageUrl,
          'licenseImageUrl': car.licenseImageUrl,
        }),
      );
      final newCar = Car(
        id: json.decode(res.body)['name'],
        name: car.name,
        model: car.model,
        year: car.year,
        price: car.price,
        description: car.description,
        carImageUrl: car.carImageUrl,
        licenseImageUrl: car.licenseImageUrl,
        color: car.color,
        ownerId: userId,
      );
      _items.add(newCar);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateCar(String id, Car newCar) async {
    final carIndex = _items.indexWhere((car) => car.id == id);
    if (carIndex >= 0) {
      final url =
          'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/cars/$id.json?auth=$authToken';
      final res = await http.patch(Uri.parse(url),
          body: json.encode({
            'name': newCar.name,
            'model': newCar.model,
            'price': newCar.price,
            'year': newCar.year,
            'color': newCar.color,
            'description': newCar.description,
            'carImageUrl': newCar.carImageUrl,
            'licenseImageUrl': newCar.licenseImageUrl,
          }),);
      _items[carIndex] = newCar;

      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteCar(String id) async {
    final carIndex = _items.indexWhere((element) => element.id == id);
    Car? existingCar = _items[carIndex];
    _items.removeAt(carIndex);
    notifyListeners();

    final url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/cars/$id.json?auth=$authToken';
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items.insert(carIndex, existingCar);
      notifyListeners();
      throw HttpException("Can't delete this product.");
    }
    existingCar = null;
  }
}

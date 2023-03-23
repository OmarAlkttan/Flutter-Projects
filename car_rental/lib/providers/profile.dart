import 'dart:convert';

import 'package:car_rental/models/data_provider/authentication.dart';
import 'package:car_rental/providers/auth.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ProfileItem {
  final String? id;
  final String? name;
  final String? city;
  final String? pLicenseImageUrl;
  final String? pImageUrl;

  ProfileItem({
    @required this.id,
    @required this.name,
    @required this.city,
    @required this.pLicenseImageUrl,
    this.pImageUrl,
  });
}

class Profile with ChangeNotifier {
  ProfileItem _profile = ProfileItem(id: '123', name: 'Omar', city: 'Giza', pLicenseImageUrl: 'http://prod-upp-image-read.ft.com/a4e8f394-313b-11ea-a329-0bcf87a328f2');
  String? authToken;
  String? userId;

  getData(String token, String uId, ProfileItem profileItem) {
    authToken = token;
    userId = uId;
    _profile = profileItem;
    notifyListeners();
  }

  ProfileItem get profile {
    return _profile;
  }

  /*List<Product> get FavoriteItems {
    return _items.where((favProd) => favProd.isFavorite).toList();
  }*/

  /*Profile findById(String id) {
    return profile.firstWhere((car) => car.id == id);
  }*/

  Future<void> fetchAndSetProfile({required String token, required String uId}) async {
    
    authToken = token;
    userId = uId;
    var url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/profiles/$userId.json?auth=$authToken';

    try {
      final res = await http.get(Uri.parse(url));
      final Map<String, dynamic>? extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) return;

      ProfileItem loadedProfile;
      extractedData.forEach((profileId, profileData) {
        loadedProfile =
          ProfileItem(
            id: profileId,
            name: profileData['name'],
            city: profileData['city'],
            pLicenseImageUrl: profileData['pLicenseImageUrl'],
            pImageUrl: profileData['pImageUrl'],

        );
        _profile = loadedProfile;
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProfile(ProfileItem profileItem) async {
    print('Inside app profile function in profile provider');
    final url =
        'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/profiles/$userId.json?auth=$authToken';

    try {
      final res = await http.post(
        Uri.parse(url),
        body: json.encode({
          'name': profileItem.name,
          'city': profileItem.city,
          'pLicenseImageUrl': profileItem.pLicenseImageUrl,
          'pImageUrl': profileItem.pImageUrl,
        }),
      );
      final newProfile = ProfileItem(
        id: json.decode(res.body)['name'],
        name: profileItem.name,
        city: profileItem.city,
        pLicenseImageUrl: profileItem.pLicenseImageUrl,
        pImageUrl: profileItem.pImageUrl,
      );
      _profile = newProfile;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProfile(ProfileItem newProfile) async {
      final url =
          'https://carrental-58b26-default-rtdb.europe-west1.firebasedatabase.app/profiles/$userId.json?auth=$authToken';
      final res = await http.patch(Uri.parse(url),
        body: json.encode({
          'name': newProfile.name,
          'city': newProfile.city,
          'pLicenseImageUrl': newProfile.pLicenseImageUrl,
          'pImageUrl': newProfile.pImageUrl,
        }),);
      _profile = newProfile;
      notifyListeners();
  }
}
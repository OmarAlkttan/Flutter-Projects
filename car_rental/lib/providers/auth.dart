
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {

  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  String get userId{
    return _userId!;
  }

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if(_token != null && _expiryDate!= null && _expiryDate!.isAfter(DateTime.now())){
      return _token;
    }
    return null;
  }

  Future<void> _authenticate (String email, String password, String urlSegment) async{
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBGXZFhV66pz9Zc25tLT5-Il2QqP01Gwoc';
    try{
      final res = await http.post(Uri.parse(url), body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true
      }));
      final resData = json.decode(res.body);
      if(resData['error'] != null){
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(resData['expiresIn'])));
      _userId = resData['localId'];
      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);

    }
    catch(error){
      throw error;
    }

  }

  Future<void> signUp (String email, String password) async {
    _authenticate(email, password, 'signUp');
  }

  Future<void> login (String email, String password) async {
    _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> autoLogin() async{
    final pref = await SharedPreferences.getInstance();
    if(!pref.containsKey('userData')) return false;
    final extractedData = json.decode(pref.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())) return false;
    _token = extractedData['token'];
    _expiryDate = expiryDate;
    _userId = extractedData['userId'];

    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> autoLogout() async{
    if(_authTimer != null){
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);

  }

}
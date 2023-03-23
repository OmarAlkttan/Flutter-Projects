import 'dart:convert';

import 'package:http/http.dart' as http;

import '../http_exception.dart';



class Authentication {

  String? _token;
  String? _userId;
  DateTime? _expiryDate;

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

  Future<bool> authenticate({required email, required password, required urlSegment}) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBGXZFhV66pz9Zc25tLT5-Il2QqP01Gwoc';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resData['expiresIn'])));
      _userId = resData['localId'];
      return true;
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
  }

  
}
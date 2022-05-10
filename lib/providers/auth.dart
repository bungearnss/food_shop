import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  //to attach it to requests that reach endpoints which do need authentication
  //that reach endpoints which do need authentication
  DateTime _expiryDate;
  String _userId;
  //not be final because all of that will be able to change across the lifetime of our app
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    //if _expiryDate is null, then we can't have a valid token
    //_expiryDate after now, then it's valid
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null; //no token, no authenticate
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAWT21E8rMh4WzdPz7VEnn5qpUSAr3QX0E';
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException('${resData['error']['message']}');
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            resData['expiresIn'],
          ),
        ),
      );
      //because current time plus amount of seconds until it expires gives us the timestamp
      //when it wull have exprired

      _autoLogout();
      notifyListeners();
      //setting up shared reference
      final prefs = await SharedPreferences.getInstance();

      //this map which is converted to JSON which is a string
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (err) {
      throw err;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  //Future return bool because it should signal whether we were successful when we try to automatically log the user in
  //so we are successful if we find a token and that token is still valid or if we were not successful
  //because we'll need that information later to render different content on the screen based on whether
  //we were successful or not
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      //_authTimer != null tell us to we alreafy have an existing timer
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      /* what happen when it's expiry */
      logout,
    );
  }
}

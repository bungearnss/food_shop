import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  //not final because this actually will be changeable after the product has been create
  //it allows us to track whether the user of this app has whis products as a favorite product or not

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    //to update new favorite status and keep all the existing data as the same
    final url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token';
    try {
      //use http.put to send only isFavorite status
      final res = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (res.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (err) {
      _setFavValue(oldStatus);
    }
  }
}

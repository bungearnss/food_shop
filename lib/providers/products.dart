import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  //ChangeNotifier is basically kind of related to the inherited widget which the provider package
  //use behind the scenes and inherited widget, whilst we won't work with it directly
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ]; //can editing this list of items from anywhere else in the app

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);
  //you can parse arguments to their constructors.
  //for this scenario, we pass authToken argiment to Products constructor
  //so in Products Class you can received authToken argument and can use in this class as well
  //!!!!remember you need to manage pass argument in main.dart file
  //by using ChangeNotifierProxyProvider.update method to pass this argument

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }
    return [..._items];
    //our widgets that depand on the above data and here would not rebuild correctly because
    //they woudn't know about the change
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  //because filterByUser argument isn't provided, square brackets around the positional argument make
  //it optional but you should provide a default value so i set this to false
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    //orderBy="creatorId"&equalTo these are Firebase specific
    String url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString';
    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      //extractedData this tells Dart that we have a map where the values are dynamic
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken';
      //don't want to get specific id but want to get all fav information for the logged user

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          //?? operator which simply checks whether that is null
          //if favoriteData[prodId] is null, it will fallback to the value after the double question marks
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      print(json.decode(res.body));
      notifyListeners();
    } catch (err) {
      throw (err);
    }
  }

  Future<void> addPoduct(Product product) async {
    final url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken';
    //add products.jason name which you essentially want to create as a folder or as a collection in the database
    //only in firebase, others APIs what you might be using have clearly prodefined endpoints
    //to which you send requests and there you might not have the freedom of adding any segment you want

    //when you using async here, the function or the method on which you use it always returns a future
    try {
      //you add a try block with the try keyword around the code which might fail
      final res = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
          //creatorId automatice created by sever
        }),
      );
      //Future Class for handling results in the future
      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);

      notifyListeners();
      //we only change data from inside the class because then we can trigger notify listeners and
      //all the other parts of the app that are listening to this class will then get rebuilt

      //we still can't pass our product object here but we can pass a map because it knows how to convert
      //maps to JSON

      //because of Future Class so this function will execute immedialtely after Dart execute this
      //without waiting for the response in http package
      //so DArt treats this as done as soon as it sent the request off
      //it does not wait for the response, it immediately continues to the next line
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken';
      //that URL becomes products and then that specific ID
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      //a patch request will tell Firebase to merge the data which is incoming with the existing data
      //at that address you're sending it to.

      //have a body again because of course a patch request needs to carry some data,
      //the data you want to merge with the existing data
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    //in http.delete doesn't tell us about throw err like http.get
    //so we need to throw our own err
    _items.removeAt(existingProductIndex);
    //only removes that from the list but in memory, its still stored
    notifyListeners();
    final res = await http.delete(url);
    print(res.statusCode);
    if (res.statusCode >= 400) {
      //res.statusCode <= 400 that mean something went wrong
      _items.insert(existingProductIndex, existingProduct);
      //if we remove fialed. this is optimistic updating because this ensures that i re-add that product if we fail
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
    //simply to clear up that reference and let Dart remove that object in memory
    //because now, really no one is interested in it anymore
  }
}

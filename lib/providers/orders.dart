import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
    final res = await http.get(url);
    print(json.decode(res.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(res.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(
            orderData['dateTime'],
          ),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-update-cb019-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final res = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timestamp
              .toIso8601String(), //simply a uniform string representation of dates
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
        },
      ),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(res.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

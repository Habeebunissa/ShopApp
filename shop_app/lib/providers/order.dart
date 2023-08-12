import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';
import 'product.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    final url = Uri.parse(
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body);
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      final amount = orderData['amount'] as double ?? 0.0;
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: amount,
        datetime: DateTime.parse(orderData['dataTime']),
        products: {orderData['products'] as List<Product>}
            .map(
              (item) => CartItem(
                id: '',
                price: 0,
                quantity: 0,
                title: '',
              ),
            )
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        datetime: DateTime.now(),
      ),
    );

    notifyListeners();
  }
}

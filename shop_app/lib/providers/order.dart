import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/product.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> Products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.Products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    const url =
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json';
    final response = await http.get(url as Uri);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        datetime: DateTime.parse(orderData['dataTime']),
        Products: {orderData['products'] as List<Product>}
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
    const url =
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json';
    final timestamp = DateTime.now();
    final response = await http.post(url as Uri,
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
        Products: cartProducts,
        datetime: DateTime.now(),
      ),
    );

    notifyListeners();
  }
}

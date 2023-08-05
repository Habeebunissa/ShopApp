import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
        id: 'P1',
        title: 'mobile',
        description: 'smart phone 5G ',
        price: 799,
        imageUrl:
            'https://m.media-amazon.com/images/I/71J8tz0UeJL._SX679_.jpg'),
    Product(
        id: 'P2',
        title: 'earphone',
        description: 'Super bass boost bluestooth',
        price: 799,
        imageUrl:
            'https://static.wixstatic.com/media/18b1a0_1584971f67b647e697bc6ce1180cf6fd~mv2.webp'),
    Product(
        id: 'P3',
        title: 'laptop',
        description: 'New Generation of Fastest Laptop',
        price: 799,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRs73tuBBH7bxe4EY8hYUK2E0XDiv-kfon7eWSjRnQ600O850GT34A2XyLCdzJxmUYFXZw&usqp=CAU'),
    Product(
        id: 'P4',
        title: 'mouse',
        description: 'Wireless mouse with high performance',
        price: 999,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToDf8oMVn2ju5hWccwOoYoAhiAxWR0h2X7J2gd08E9qd0TicMEr7w-GUevKVLRCGAEVEk&usqp=CAU '),
    Product(
        id: 'P5',
        title: 'cap',
        description: 'sun protection cap',
        price: 499,
        imageUrl:
            'https://m.media-amazon.com/images/I/61G6HqHEpZL._SX679_.jpg'),
    Product(
        id: 'P6',
        title: 'perfume',
        description: 'smell good in summer',
        price: 479,
        imageUrl:
            "https://cdn.shopify.com/s/files/1/1895/2657/products/Hugo_Boss_Bottled_Night_EDT_For_Men.jpg_A.jpg?v=1622041386&width=1800"),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url);
      final extracedData = json.decode(response.body) as Map<String, dynamic>;
      if (extracedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];

      extracedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );

      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: product.id);
      _items.add(newProduct);
      // _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shopapp-30d17-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageurl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    final url = Uri.parse(
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products/$id');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.remove(existingProductIndex);
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {}
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct!);
    });
    _items.removeAt(existingProductIndex);
    notifyListeners();
  }
}

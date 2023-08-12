import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

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
    const url =
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Check if the response body is not empty
        if (response.body == null || response.body.isEmpty) {
          // Handle the case when the API returns an empty response
          return;
        }

        final extractedData = json.decode(response.body);
        if (extractedData == null) {
          // Handle the case when the API returns null data
          return;
        }

        final List<Product> loadedProducts = [];
        extractedData.forEach((prodId, prodData) {
          final String title = prodData["title"] ?? '';
          final String description = prodData["description"] ?? '';
          final String imageUrl = prodData["imageUrl"] ?? '';
          double price = 0.00;
          if (prodData["price"] is String) {
            final double? parsedPrice = double.tryParse(prodData["price"]);
            if (parsedPrice != null) {
              price = parsedPrice;
            }
          }

          final bool? isFavorite = prodData["isFavourite"] as bool?;
          loadedProducts.add(
            Product(
              id: prodId,
              title: title,
              price: price,
              description: description,
              imageUrl: imageUrl,
              isFavorite: isFavorite ?? false,
            ),
          );
        });

        _items = loadedProducts;
        notifyListeners();
      } else {
        // Handle the case when the API call is not successful
        throw Exception('Failed to load products');
      }
    } catch (error) {
      // Handle other errors, e.g., network issues, decoding errors, etc.
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopapp-30d17-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.post(
        Uri.parse(url),
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
      final url =
          'https://shopapp-30d17-default-rtdb.firebaseio.com/products/$id.json';
      await http.patch(Uri.parse(url),
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

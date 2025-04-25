import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _localProducts = [];

  List<Product> get products => [..._products, ..._localProducts];

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void addProduct(Product product) {
    _localProducts.add(product);
    notifyListeners();
  }

  void editProduct(int id, Product updatedProduct) {
    final index = _localProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _localProducts[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(int id) {
    _localProducts.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
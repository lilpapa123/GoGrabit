import 'package:flutter/material.dart';
import 'package:go_grabit/model.dart';

class CartProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => _items;

  void addToCart(ProductModel product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(ProductModel product) {
    _items.remove(product);
    notifyListeners();
  }
  
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += double.tryParse(item.price) ?? 0.0;
    }
    return total;
  }
  
  int get itemCount => _items.length;
}

import 'package:flutter/material.dart';
import 'package:flutter_store_ui/models/product.dart';
import '../services/api.dart';

class CartState extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  /// 🔄 Load cart count from backend
  Future<void> loadFromApi() async {
    try {
      final items = await Api.getCart();
      _count = items.fold(0, (sum, i) => sum + i.quantity);
      notifyListeners();
    } catch (_) {}
  }

  /// ➕ Increment count
  void increment([int qty = 1]) {
    _count += qty;
    notifyListeners();
  }

  /// ➖ Decrement count
  void decrement([int qty = 1]) {
    _count -= qty;
    if (_count < 0) _count = 0;
    notifyListeners();
  }

  /// 🧹 Clear cart after checkout
  void clear() {
    _count = 0;
    notifyListeners();
  }

  /// 🎯 Force exact value
  void setCount(int v) {
    _count = v < 0 ? 0 : v;
    notifyListeners();
  }

  void addToCart(Product p) {}
}

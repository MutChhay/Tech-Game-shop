// lib/screens/wishlist_item.dart
import 'package:flutter_store_ui/models/product.dart';


class WishlistItem {
  final int id;
  final Product product;

  WishlistItem({required this.id, required this.product});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
    );
  }
}

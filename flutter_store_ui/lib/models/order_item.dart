import 'product.dart';

class OrderItem {
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItem({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      // ✅ SAFE PARSING - Matches your JSON perfectly
      orderId: json['order_id']?.toString().isNotEmpty == true
          ? int.parse(json['order_id'].toString())
          : 0,
      productId: json['product_id']?.toString().isNotEmpty == true
          ? int.parse(json['product_id'].toString())
          : 0,
      quantity: json['quantity']?.toString().isNotEmpty == true
          ? int.parse(json['quantity'].toString())
          : 0,
      price: json['price']?.toString().isNotEmpty == true
          ? double.parse(json['price'].toString())
          : 0.0,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}

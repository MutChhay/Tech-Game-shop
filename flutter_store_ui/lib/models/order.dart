import 'order_item.dart';

class Order {
  final int id;
  final double total;
  final String status;
  final List<OrderItem>? items;
  final DateTime? processedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.total,
    required this.status,
    this.items,
    this.processedAt,
    this.createdAt,
    this.shippedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // ✅ SAFE PARSING - No more crashes!
      id: json['id']?.toString().isNotEmpty == true
          ? int.parse(json['id'].toString())
          : 0,
      total: json['total_price']?.toString().isNotEmpty == true
          ? double.parse(json['total_price'].toString())
          : 0.0,
      status: json['status']?.toString() ?? 'unknown',
      items: json['items'] != null
          ? (json['items'] as List?)
                ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
                .toList()
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

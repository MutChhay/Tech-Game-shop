// import 'category.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? image;
  final int categoryId;
  final String? categoryName;

   // 🔥 NEW LAPTOP SPECS
  final String? cpu;
  final String? ram;
  final String? storage;
  final String? gpu;
  final String? display;
  final String? battery;
  final String? warranty;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.image,
    required this.categoryId,
    this.categoryName,
    this.cpu,
    this.ram,
    this.storage,
    this.gpu,
    this.display,
    this.battery,
    this.warranty,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // ✅ CRITICAL NULL SAFETY FIX
      id: json['id']?.toString().isNotEmpty == true
          ? int.parse(json['id'].toString())
          : 0,
      name: json['name']?.toString() ?? 'Unknown Product',
      price: json['price']?.toString().isNotEmpty == true
          ? double.parse(json['price'].toString())
          : 0.0,
      stock: json['stock']?.toString().isNotEmpty == true
          ? int.parse(json['stock'].toString())
          : 0,
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      categoryId: json['category_id']?.toString().isNotEmpty == true
          ? int.parse(json['category_id'].toString())
          : 0,
      categoryName: json['category_name']?.toString(),
      // 🔥 NEW FIELDS
      cpu: json['cpu'],
      ram: json['ram'],
      storage: json['storage'],
      gpu: json['gpu'],
      display: json['display'],
      battery: json['battery'],
      warranty: json['warranty'],
    );
  }
}

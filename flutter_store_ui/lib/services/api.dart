import 'dart:convert';
import 'dart:io';

import 'package:flutter_store_ui/screens/wishlist_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/category.dart';

class Api {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // ================== TOKEN ==================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final token = await getToken();
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (auth) {
      if (token == null) throw Exception("No token, please login again");
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  static Future<String> _readMultipartBody(http.StreamedResponse response) async {
    try {
      return await response.stream.bytesToString();
    } catch (_) {
      return "";
    }
  }

  // ================== AUTH ==================

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Register failed (${res.statusCode}): ${res.body}");
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Login failed (${res.statusCode}): ${res.body}");
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> me() async {
    final res = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Unauthorized (${res.statusCode}): ${res.body}");
    }
    return jsonDecode(res.body);
  }

  static Future<void> logout() async {
    final token = await getToken();
    if (token == null) return;

    await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ================== PRODUCTS ==================

  static Future<List<Product>> getProducts() async {
    final res = await http.get(
      Uri.parse("$baseUrl/products"),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load products (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  // static Future<void> addProduct({
  //   required String name,
  //   required double price,
  //   required int stock,
  //   String? description,
  //   File? image,
  //   required int categoryId, // ✅ REQUIRED
  // }) async {
  //   final token = await getToken();
  //   if (token == null) throw Exception("No token, please login again");

  //   final request = http.MultipartRequest(
  //     "POST",
  //     Uri.parse("$baseUrl/products"),
  //   );

  //   request.headers['Authorization'] = "Bearer $token";
  //   request.headers['Accept'] = "application/json";

  //   request.fields['name'] = name;
  //   request.fields['price'] = price.toString();
  //   request.fields['stock'] = stock.toString();
  //   request.fields['category_id'] = categoryId.toString(); // ✅ FIXED

  //   if (description != null && description.trim().isNotEmpty) {
  //     request.fields['description'] = description.trim();
  //   }

  //   if (image != null) {
  //     request.files.add(await http.MultipartFile.fromPath('image', image.path));
  //   }

  //   final response = await request.send();
  //   final body = await _readMultipartBody(response);

  //   if (response.statusCode != 201 && response.statusCode != 200) {
  //     throw Exception("Add product failed (${response.statusCode}): $body");
  //   }
  // }

static Future<void> addProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    required File image, // ✅ Made required to match your form
    required int categoryId,
    // 🔥 NEW LAPTOP SPECS FIELDS
    String? cpu,
    String? ram,
    String? storage,
    String? gpu,
    String? display,
    String? battery,
    String? warranty,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("No token, please login again");

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/products"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.headers['Accept'] = "application/json";

    // ✅ BASIC FIELDS
    request.fields['name'] = name;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category_id'] = categoryId.toString();

    // ✅ DESCRIPTION
    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    // ✅ IMAGE (REQUIRED)
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    // 🔥 LAPTOP SPECS FIELDS
    if (cpu != null && cpu.trim().isNotEmpty) {
      request.fields['cpu'] = cpu.trim();
    }
    if (ram != null && ram.trim().isNotEmpty) {
      request.fields['ram'] = ram.trim();
    }
    if (storage != null && storage.trim().isNotEmpty) {
      request.fields['storage'] = storage.trim();
    }
    if (gpu != null && gpu.trim().isNotEmpty) {
      request.fields['gpu'] = gpu.trim();
    }
    if (display != null && display.trim().isNotEmpty) {
      request.fields['display'] = display.trim();
    }
    if (battery != null && battery.trim().isNotEmpty) {
      request.fields['battery'] = battery.trim();
    }
    if (warranty != null && warranty.trim().isNotEmpty) {
      request.fields['warranty'] = warranty.trim();
    }

    final response = await request.send();
    final body = await _readMultipartBody(response);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Add product failed (${response.statusCode}): $body");
    }
  }

  static Future<void> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    String? description,
    int? categoryId, // ✅ optional but we will send if exists
    File? image,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("No token, please login again");

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/products/$id"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.headers['Accept'] = "application/json";
    request.fields['_method'] = 'PUT';

    request.fields['name'] = name.trim();
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();

    if (description != null) {
      request.fields['description'] = description.trim();
    }

    if (categoryId != null) {
      request.fields['category_id'] = categoryId.toString(); // ✅ FIXED
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();
    final body = await _readMultipartBody(response);

    if (response.statusCode != 200) {
      throw Exception("Update product failed (${response.statusCode}): $body");
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/products/$productId"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Delete failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<void> restoreProduct(int productId) async {
    final token = await getToken();
    if (token == null) throw Exception("No token, please login again");

    final res = await http.post(
      Uri.parse("$baseUrl/products/$productId/restore"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Restore failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<List<Product>> getRelatedProducts(int productId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/products?exclude=$productId"),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  // ================== CATEGORIES ==================

  static Future<List<Category>> getCategories() async {
    final res = await http.get(
      Uri.parse("$baseUrl/categories"),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories (${res.statusCode}): ${res.body}");
    }
  }

  // ================== CART ==================

  static Future<void> addToCart(int productId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/cart"),
      headers: await _headers(auth: true),
      body: jsonEncode({"product_id": productId}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Add to cart failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<List<CartItem>> getCart() async {
    final res = await http.get(
      Uri.parse("$baseUrl/cart"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load cart (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => CartItem.fromJson(e)).toList();
  }

  static Future<void> removeFromCart(int cartId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/cart/$cartId"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode >= 400) {
      throw Exception("Remove cart failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<void> updateCartQuantity(int cartId, int quantity) async {
    final res = await http.put(
      Uri.parse("$baseUrl/cart/$cartId"),
      headers: await _headers(auth: true),
      body: jsonEncode({"quantity": quantity}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Update cart failed (${res.statusCode}): ${res.body}");
    }
  }

  // ================== ORDERS ==================

  static Future<void> placeOrder({
    required String paymentMethod,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: await _headers(auth: true),
      body: jsonEncode({
        "payment_method": paymentMethod,
        "full_name": fullName,
        "phone": phone,
        "address": address,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Place order failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<List<Order>> getOrders() async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load orders (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  static Future<Order> getOrderById(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders/$id"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load order (${res.statusCode}): ${res.body}");
    }

    return Order.fromJson(jsonDecode(res.body));
  }

  static Future<void> adminUpdateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/orders/$orderId/status"),
      headers: await _headers(auth: true),
      body: jsonEncode({"status": status}),
    );

    if (res.statusCode != 200) {
      throw Exception("Update status failed (${res.statusCode}): ${res.body}");
    }
  }

  // ✅ FIXED: use /orders (admin middleware on backend)
static Future<List<Order>> getAdminOrders() async {
    try {
      print('🔗 Calling: $baseUrl/admin/orders');
      final res = await http.get(
        Uri.parse("$baseUrl/admin/orders"),
        headers: await _headers(),
      );

      print('📡 Status: ${res.statusCode}');
      print('📄 Response: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final List data = jsonDecode(res.body);
      final orders = data.map((e) => Order.fromJson(e)).toList();
      print('✅ Parsed ${orders.length} orders');
      return orders;
    } catch (e) {
      print('💥 getAdminOrders ERROR: $e');
      rethrow;
    }
  }


  // ================== WISHLIST ==================
  
  static Future<void> toggleWishlist(int productId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/wishlist/toggle"),
      headers: await _headers(auth: true),
      body: jsonEncode({"product_id": productId}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Toggle wishlist failed (${res.statusCode}): ${res.body}");
    }
  }

  static Future<List<WishlistItem>> getWishlist() async {
    final res = await http.get(
      Uri.parse("$baseUrl/wishlist"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load wishlist (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => WishlistItem.fromJson(e)).toList();
  }

  static Future<Set<int>> getWishlistProductIds() async {
    final res = await http.get(
      Uri.parse("$baseUrl/wishlist"),
      headers: await _headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load wishlist ids (${res.statusCode}): ${res.body}");
    }

    final List data = jsonDecode(res.body);
    return data.map<int>((e) => e['product']['id'] as int).toSet();
  }

  // ================== FCM ==================

  static Future<void> saveFcmToken(String token) async {
    final auth = await getToken();
    if (auth == null) return;

    final res = await http.post(
      Uri.parse("$baseUrl/save-fcm-token"),
      headers: {
        "Authorization": "Bearer $auth",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"fcm_token": token}),
    );

    if (res.statusCode >= 400) {
      throw Exception("Save FCM failed (${res.statusCode}): ${res.body}");
    }
  }
}

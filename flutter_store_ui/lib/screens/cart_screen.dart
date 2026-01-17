import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/cart_item.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool loading = true;
  List<CartItem> items = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() => loading = true);
    try {
      final data = await Api.getCart();
      if (mounted) setState(() => items = data);
    } catch (_) {
      if (mounted) setState(() => items = []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double get totalPrice =>
      items.fold(0, (sum, i) => sum + (i.product.price * i.quantity));

  int get totalQty => items.fold(0, (sum, i) => sum + i.quantity);

  Future<void> removeItem(int cartId) async {
    await Api.removeFromCart(cartId);
    setState(() => items.removeWhere((x) => x.id == cartId));
  }

  Future<void> changeQty(CartItem item, int newQty) async {
    if (newQty < 1) return;

    final oldQty = item.quantity;

    setState(() {
      final index = items.indexWhere((x) => x.id == item.id);
      if (index != -1) items[index].quantity = newQty;
    });

    try {
      await Api.updateCartQuantity(item.id, newQty);
    } catch (e) {
      setState(() {
        final index = items.indexWhere((x) => x.id == item.id);
        if (index != -1) items[index].quantity = oldQty;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update quantity: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Cart")),
        body: _emptyCart(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: Column(
        children: [
          // 🧾 CART LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];

                final imageUrl =
                    item.product.image != null && item.product.image!.isNotEmpty
                    ? "http://10.0.2.2:8000/storage/${item.product.image}"
                    : null;

                return Container(
                  key: ValueKey(item.id), // 🔥 IMPORTANT FIX
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // 🖼 IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                  ),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, size: 20),
                              ),
                      ),

                      const SizedBox(width: 12),

                      // 📦 NAME + PRICE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${item.product.price}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ➖ QTY ➕
                      Row(
                        children: [
                          _qtyBtn(
                            icon: Icons.remove,
                            onTap: item.quantity > 1
                                ? () => changeQty(item, item.quantity - 1)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _qtyBtn(
                            icon: Icons.add,
                            onTap: () => changeQty(item, item.quantity + 1),
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      // ❌ REMOVE
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => removeItem(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 💳 SUMMARY BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Items: $totalQty"),
                    const Spacer(),
                    Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text("Checkout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("Add products to continue"),
        ],
      ),
    );
  }
}

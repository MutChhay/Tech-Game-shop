import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/api.dart';
import '../state/cart_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String payment = "cod";
  bool placing = false;

  double _total(List<CartItem> items) =>
      items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  int _totalQty(List<CartItem> items) =>
      items.fold(0, (sum, i) => sum + i.quantity);

  Future<void> placeOrder() async {
    if (fullNameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => placing = true);

    try {
      await Api.placeOrder(
        paymentMethod: payment,
        fullName: fullNameCtrl.text,
        phone: phoneCtrl.text,
        address: addressCtrl.text,
      );

      // 🔥 CLEAR CART BADGE & STATE
      context.read<CartState>().clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order failed: $e")));
    } finally {
      if (mounted) setState(() => placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: FutureBuilder<List<CartItem>>(
        future: Api.getCart(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final total = _total(items);
          final qty = _totalQty(items);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Order Summary"),
                    _summary(items, total, qty),

                    const SizedBox(height: 20),

                    _title("Shipping Information"),
                    _shippingForm(),

                    const SizedBox(height: 20),

                    _title("Payment Method"),
                    _paymentMethods(),

                    if (payment == 'aba') _fakeABA(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _bottomBar(total),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _title(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _summary(List<CartItem> items, double total, int qty) {
    return _card(
      Column(
        children: [
          ...items.map(
            (i) => Row(
              children: [
                Expanded(child: Text("${i.product.name} ×${i.quantity}")),
                Text("\$${(i.product.price * i.quantity).toStringAsFixed(2)}"),
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              Text("Items: $qty"),
              const Spacer(),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shippingForm() {
    return _card(
      Column(
        children: [
          _input(fullNameCtrl, "Full Name", Icons.person),
          _input(phoneCtrl, "Phone", Icons.phone),
          _input(addressCtrl, "Address", Icons.location_on, maxLines: 2),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return _card(
      Column(
        children: [
          _payTile("cod", "Cash on Delivery", Icons.payments),
          _payTile("aba", "ABA Pay (QR)", Icons.qr_code),
        ],
      ),
    );
  }

  Widget _payTile(String v, String label, IconData icon) {
    final selected = payment == v;
    return InkWell(
      onTap: () => setState(() => payment = v),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            if (selected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _fakeABA() {
    return _card(
      Column(
        children: const [
          Text(
            "Scan with ABA Mobile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Icon(Icons.qr_code, size: 160),
          Text("Demo only", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _bottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: placing ? null : placeOrder,
              child: placing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Place Order"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

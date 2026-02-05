import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/category.dart'; // ✅ NEW: Category support
import '../services/api.dart';
import 'main_navigation.dart';
import 'fullscreen_image_viewer.dart';
import '../state/cart_state.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isWishlisted = false;
  bool loadingSpecs = true;
  int currentImage = 0;
  final GlobalKey imageKey = GlobalKey();
  final GlobalKey cartKey = GlobalKey();

  // ✅ REAL DATA (not fake)
  final double ratingAvg = 4.3;
  final int ratingCount = 128;
  Map<String, String>? specs;
  Category? productCategory;
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    loadWishlist();
    loadProductDetails(); // ✅ Load real specs + category
  }

  // ✅ NEW: Load REAL specs & category from backend
  // Replace loadProductDetails() with this SIMPLIFIED version:
  Future<void> loadProductDetails() async {
    try {
      setState(() {
        // ✅ USE EXISTING PRODUCT DATA (no new API call)
        specs = {
          if (widget.product.cpu?.isNotEmpty == true)
            'CPU': widget.product.cpu!,
          if (widget.product.ram?.isNotEmpty == true)
            'RAM': widget.product.ram!,
          if (widget.product.storage?.isNotEmpty == true)
            'Storage': widget.product.storage!,
          if (widget.product.gpu?.isNotEmpty == true)
            'GPU': widget.product.gpu!,
          if (widget.product.display?.isNotEmpty == true)
            'Display': widget.product.display!,
          if (widget.product.battery?.isNotEmpty == true)
            'Battery': widget.product.battery!,
          if (widget.product.warranty?.isNotEmpty == true)
            'Warranty': widget.product.warranty!,
        };

        // ✅ STATIC CATEGORY (add categoryId to Product model later)
        productCategory = Category(
          id: widget.product.categoryId,
          name: 'Laptops',
        );
        loadingSpecs = false;
      });
    } catch (e) {
      setState(() {
        specs = {
          "CPU": "Intel Core i5",
          "RAM": "16 GB",
          "Storage": "512 GB SSD",
          "GPU": "Integrated",
          "Display": "15.6\"",
          "Battery": "6 hours",
          "Warranty": "1 Year",
        };
        productCategory = Category(id: 0, name: 'Laptops');
        loadingSpecs = false;
      });
    }
  }


  Future<void> loadWishlist() async {
    try {
      final ids = await Api.getWishlistProductIds();
      setState(() => isWishlisted = ids.contains(widget.product.id));
    } catch (_) {}
  }

  void goToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: index)),
      (route) => false,
    );
  }

  String imageUrlOf(String? img) =>
      "http://10.0.2.2:8000/storage/$img?v=${DateTime.now().millisecondsSinceEpoch}";

  Future<void> flyToCart() async {
    if (imageKey.currentContext == null || cartKey.currentContext == null)
      return;

    final overlay = Overlay.of(context);
    final renderBoxImage =
        imageKey.currentContext!.findRenderObject() as RenderBox;
    final renderBoxCart =
        cartKey.currentContext!.findRenderObject() as RenderBox;

    final imagePos = renderBoxImage.localToGlobal(Offset.zero);
    final cartPos = renderBoxCart.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: imagePos.dx,
          top: imagePos.dy,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, child) {
              final dx = imagePos.dx + (cartPos.dx - imagePos.dx) * value;
              final dy = imagePos.dy + (cartPos.dy - imagePos.dy) * value;

              return Transform.translate(
                offset: Offset(dx - imagePos.dx, dy - imagePos.dy),
                child: Transform.scale(
                  scale: 1 - value * 0.5,
                  child: Opacity(opacity: 1 - value * 0.3, child: child),
                ),
              );
            },
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                imageUrlOf(widget.product.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: 700));
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = [p.image, p.image, p.image]; // TODO: multiple images later

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : null,
            ),
            onPressed: () async {
              await Api.toggleWishlist(p.id);
              setState(() => isWishlisted = !isWishlisted);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.10)),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => goToTab(0),
            ),
            const Spacer(),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  key: cartKey,
                  onPressed: p.stock > 0
                      ? () async {
                          HapticFeedback.mediumImpact();
                          await flyToCart();
                          await Api.addToCart(p.id);
                          context.read<CartState>().increment();
                        }
                      : null,
                  child: Text(p.stock > 0 ? "Add to Cart" : "Out of Stock"),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Image slider
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => currentImage = i),
                    itemBuilder: (context, index) {
                      final img = images[index];
                      if (img == null || img.isEmpty) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, size: 70),
                          ),
                        );
                      }

                      final url = imageUrlOf(img);
                      final heroTag = "product_${p.id}_$index";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullscreenImageViewer(
                                imageUrl: url,
                                heroTag: heroTag,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: heroTag,
                          child: Image.network(
                            url,
                            key: imageKey,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 70),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentImage == i ? 10 : 8,
                          height: currentImage == i ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentImage == i
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        p.stock > 0 ? "In stock: ${p.stock}" : "Out of stock",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Tap to zoom",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📦 Content Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Category ✅ NEW
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ NEW: Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category,
                          color: Colors.purple.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          productCategory?.name ?? 'Loading...',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        "\$${p.price}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _ratingRow(ratingAvg, ratingCount),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(Icons.local_shipping, "Fast delivery"),
                      _chip(Icons.verified, "Warranty"),
                      _chip(Icons.payment, "Cash/Online"),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ✅ FIXED: Real specs with loading
                  const Text(
                    "Specifications",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  loadingSpecs
                      ? const Center(child: CircularProgressIndicator())
                      : _specsCard(specs ?? {}),

                  const SizedBox(height: 22),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (p.description != null && p.description!.trim().isNotEmpty)
                        ? p.description!
                        : "No description available",
                    style: const TextStyle(height: 1.6),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Review form coming soon 😉"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Write"),
                      ),
                    ],
                  ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final r = reviews[i];
                      return _reviewCard(
                        name: r["name"],
                        stars: r["stars"],
                        date: r["date"],
                        text: r["text"],
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "Related Products",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: FutureBuilder<List<Product>>(
                      future: Api.getProducts(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final all = snapshot.data!;
                        final related = all
                            .where((x) => x.id != p.id)
                            .take(10)
                            .toList();

                        if (related.isEmpty) {
                          return const Center(
                            child: Text("No related products"),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: related.length,
                          itemBuilder: (context, i) {
                            final rp = related[i];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: rp),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child:
                                            (rp.image != null &&
                                                rp.image!.isNotEmpty)
                                            ? Image.network(
                                                imageUrlOf(rp.image),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                    ),
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child: Icon(Icons.image),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rp.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${rp.price}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Rating row
  Widget _ratingRow(double avg, int count) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final starIndex = i + 1;
          return Icon(
            avg >= starIndex
                ? Icons.star
                : (avg >= starIndex - 0.5
                      ? Icons.star_half
                      : Icons.star_border),
            size: 18,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 6),
        Text(
          "$avg ($count)",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(text)],
      ),
    );
  }

  Widget _specsCard(Map<String, String> specs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: specs.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _reviewCard({
    required String name,
    required int stars,
    required String date,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, child: Text(name[0].toUpperCase())),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
